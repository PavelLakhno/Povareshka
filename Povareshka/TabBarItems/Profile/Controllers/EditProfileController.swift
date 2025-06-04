//
//  EditProfileController.swift
//  Povareshka
//
//  Created by user on 03.06.2025.
//

import UIKit
import Storage

// MARK: - Edit Profile View Controller
class EditProfileController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Components
    private let avatarImageView = UIImageView()
    private let usernameTextField = UITextField()
    private let ageTextField = UITextField()
    private let websiteTextField = UITextField()
    private let updateButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let imagePicker = UIImagePickerController()
    
    // MARK: - Properties
    var onProfileUpdated: (() -> Void)?
    private var currentAvatarURL: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialProfile()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Редактировать профиль"
        
        // Настройка аватара
        avatarImageView.configureProfileImage()
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(changeAvatarTapped))
        )
        
        // Настройка текстовых полей
        usernameTextField.configure(placeholder: "Имя", delegate: self, autocapitalization: .none)
        ageTextField.configure(placeholder: "Возраст", delegate: self)
        websiteTextField.configure(placeholder: "Сайт", keyboardType: .URL, delegate: self, autocapitalization: .none)

        // Настройка кнопки
        updateButton.configure(title: "Сохранить", color: .systemOrange)
        updateButton.addTarget(self, action: #selector(updateProfileTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let stackView = UIStackView(arrangedSubviews: [
            usernameTextField,
            ageTextField,
            websiteTextField,
            updateButton,
            activityIndicator
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(avatarImageView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    // MARK: - Actions
    @objc private func changeAvatarTapped() {
        let alert = UIAlertController(title: "Выберите изображение", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Галерея", style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Камера", style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func updateProfileTapped() {
        Task {
            do {
                activityIndicator.startAnimating()
                updateButton.isEnabled = false
                
                let imageURL = try await uploadAvatarIfNeeded()
                try await updateProfile(avatarURL: imageURL)
                
                DispatchQueue.main.async {
                    self.onProfileUpdated?()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                showError(error)
            }
            activityIndicator.stopAnimating()
            updateButton.isEnabled = true
            
        }
    }
    
    // MARK: - Private Methods
    private func loadInitialProfile() {
        Task {
            do {
                let currentUser = try await SupabaseManager.shared.client.auth.session.user
                let profile: Profile = try await fetchProfile(userId: currentUser.id)
                
                DispatchQueue.main.async {
                    self.updateUI(with: profile)
                }
            } catch {
                showError(error)
            }
        }
    }
    
    private func fetchProfile(userId: UUID) async throws -> Profile {
        return try await SupabaseManager.shared.client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }
    
    private func updateUI(with profile: Profile) {
        usernameTextField.text = profile.username
        ageTextField.text = profile.fullName
        websiteTextField.text = profile.website
        currentAvatarURL = profile.avatarURL
        
        if let avatarURL = profile.avatarURL {
            Task {
                try await loadAvatar(from: avatarURL)
            }
        }
    }
    
    private func loadAvatar(from path: String) async throws {
        let data = try await SupabaseManager.shared.client.storage
            .from("avatars")
            .download(path: path)
        
        DispatchQueue.main.async {
            self.avatarImageView.image = UIImage(data: data)
        }
    }
    
//    private func uploadAvatarIfNeeded() async throws -> String? {
//        
//        guard let image = avatarImageView.image,
//              let data = image.jpegData(compressionQuality: 0.8) else {
//            return nil
//        }
//        
//        // 1. Удаляем старый аватар (если он есть)
//        if let oldAvatarURL = currentAvatarURL {
//            try await SupabaseManager.shared.client.storage
//                .from("avatars")
//                .remove(paths: [oldAvatarURL])
//        }
//        
//        // 2. Загружаем новый
//        let fileName = "\(UUID().uuidString).jpeg"
//        try await SupabaseManager.shared.client.storage
//            .from("avatars")
//            .upload(
//                fileName,
//                data: data,
//                options: FileOptions(contentType: "image/jpeg")
//            )
//        
//        return fileName
//    }
    private func uploadAvatarIfNeeded() async throws -> String? {
        guard let image = avatarImageView.image,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let currentUser = try await SupabaseManager.shared.client.auth.session.user
        let userId = currentUser.id.uuidString.lowercased()
        
        // 1. Создаем папку пользователя, если ее нет
        let userFolderPath = "users/\(userId)/"
        let fileName = "\(UUID().uuidString).jpeg"
        let fullPath = userFolderPath + fileName
        
        // 2. Удаляем старый аватар (если он есть)
        if let oldAvatarURL = currentAvatarURL {
            try await deleteAvatar(at: oldAvatarURL)
        }
        
        // 3. Загружаем новый аватар
        try await uploadAvatar(data: imageData, path: fullPath)
        
        return fullPath
    }
    
    private func deleteAvatar(at path: String) async throws {
        do {
            try await SupabaseManager.shared.client.storage
                .from("avatars")
                .remove(paths: [path])
        } catch {
            print("Ошибка при удалении старого аватара: \(error)")
            // Можно продолжить, так как это не критическая ошибка
        }
    }
    
    private func uploadAvatar(data: Data, path: String) async throws {
        try await SupabaseManager.shared.client.storage
            .from("avatars")
            .upload(
                path,
                data: data,
                options: FileOptions(
                    contentType: "image/jpeg"
                )
            )
    }
    
    private func updateProfile(avatarURL: String?) async throws {
        let currentUser = try await SupabaseManager.shared.client.auth.session.user
        
        let updatedProfile = Profile(
            id: currentUser.id,
            username: usernameTextField.text,
            fullName: ageTextField.text,
            website: websiteTextField.text,
            avatarURL: avatarURL
        )
        
        try await SupabaseManager.shared.client
            .from("profiles")
            .update(updatedProfile)
            .eq("id", value: currentUser.id)
            .execute()
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func showError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Ошибка",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        avatarImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UI Helpers
extension UITextField {
    func configure(placeholder: String,
                   keyboardType: UIKeyboardType = .default,
                   delegate: UITextFieldDelegate? = nil,
                   autocapitalization: UITextAutocapitalizationType = .sentences) {
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.autocapitalizationType = autocapitalization
        self.clearButtonMode = .whileEditing
        self.delegate = delegate
        borderStyle = .roundedRect
        translatesAutoresizingMaskIntoConstraints = false
    }
}
