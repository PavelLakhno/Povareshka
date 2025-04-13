//
//  RegistrationController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 09.04.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

final class RegistrationController: UIViewController {
    
    var onBackTapped: (() -> Void)?
    
    // MARK: - UI Elements
//    private let contentView = UIView()
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setTitle("Назад", for: .normal)
        button.tintColor = Resources.Colors.orange
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameTextField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 12
        field.textAlignment = .left
        field.returnKeyType = .done
        field.setLeftPaddingPoints(15)
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .neutral10
        field.translatesAutoresizingMaskIntoConstraints = false
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]
        
        field.attributedPlaceholder = NSAttributedString(
            string: "Имя",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private let emailTextField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 12
        field.keyboardType = .emailAddress
        field.textAlignment = .left
        field.returnKeyType = .done
        field.setLeftPaddingPoints(15)
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .neutral10
        field.translatesAutoresizingMaskIntoConstraints = false
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]
        
        field.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private let phoneTextField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 12
        field.keyboardType = .phonePad
        field.textAlignment = .left
        field.returnKeyType = .done
        field.setLeftPaddingPoints(15)
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .neutral10
        field.translatesAutoresizingMaskIntoConstraints = false
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]
        
        field.attributedPlaceholder = NSAttributedString(
            string: "Тел. +7(123)456-78-90",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private let passwordTextField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 12
        field.isSecureTextEntry = true
        field.textAlignment = .left
        field.returnKeyType = .done
        field.setLeftPaddingPoints(15)
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .neutral10
        field.translatesAutoresizingMaskIntoConstraints = false
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]
        
        field.attributedPlaceholder = NSAttributedString(
            string: "Пароль (мин. 6 знаков)",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()

    private let genderSegmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Муж", "Жен"])
        segmentControl.layer.cornerRadius = 12
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = Resources.Colors.orange.withAlphaComponent(0.9)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.tintColor = Resources.Colors.orange
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выбрать фото", for: .normal)
        button.tintColor = Resources.Colors.orange
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Регистрация", for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var selectedImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupNavigationBar()
        setupUI()
        setupConstraints()
        
    }
    
    private func setupNavigationBar() {
//         1. Показываем навигационную панель
//        navigationController?.navigationBar.isHidden = false
        
        // 2. Настраиваем кнопку "Назад"
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        // 3. Устанавливаем кнопку
        navigationItem.leftBarButtonItem = backButton
        
        // 4. Опционально: настраиваем внешний вид
        navigationController?.navigationBar.tintColor = .orange // Цвет кнопки
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .green.withAlphaComponent(0.5)

        view.addSubview(backButton)
        view.addSubview(avatarImageView)
        view.addSubview(selectPhotoButton)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(phoneTextField)
        view.addSubview(passwordTextField)
        view.addSubview(genderSegmentedControl)
        view.addSubview(registerButton)

    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        
        let padding: CGFloat = 20
        let textFieldHeight: CGFloat = 44

        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: padding*4),
            
            avatarImageView.bottomAnchor.constraint(equalTo: selectPhotoButton.topAnchor, constant: -8),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            selectPhotoButton.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -8),
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -padding),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            nameTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            emailTextField.bottomAnchor.constraint(equalTo: phoneTextField.topAnchor, constant: -padding),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            phoneTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            phoneTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            phoneTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            phoneTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            passwordTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: padding),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            genderSegmentedControl.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            registerButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: padding),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            registerButton.heightAnchor.constraint(equalToConstant: textFieldHeight),
        ])
    }
    
    // MARK: - Actions
    @objc private func handleSelectPhoto() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func handleRegister() {
        guard
            let name = nameTextField.text, !name.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let phone = phoneTextField.text, !phone.isEmpty,
            let password = passwordTextField.text, password.count >= 6
        else {
            showAlert(title: "Error", message: "Please fill all fields correctly.")
            return
        }
        
        let gender = genderSegmentedControl.selectedSegmentIndex == 0 ? "Муж" : "Жен"
        
        // 1. Создаем пользователя в Firebase Auth (Email/Password)
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Registration Error", message: error.localizedDescription)
                return
            }
            
            guard let user = authResult?.user else { return }
            let uid = user.uid
            
            // 2. Если выбрано фото — загружаем в Storage
            if let image = self.selectedImage {
                self.uploadAvatar(image: image, userId: uid) { [weak self] avatarURL in
                    self?.saveUserData(uid: uid, name: name, email: email, phone: phone, gender: gender, avatarURL: avatarURL)
                }
            } else {
                self.saveUserData(uid: uid, name: name, email: email, phone: phone, gender: gender, avatarURL: nil)
            }
        }
    }
    
    // MARK: - Firebase Upload & Save
    private func uploadAvatar(image: UIImage, userId: String, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child("avatars/\(userId).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload avatar:", error)
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
    
    private func saveUserData(uid: String, name: String, email: String, phone: String, gender: String, avatarURL: String?) {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email,
            "phone": phone,
            "gender": gender,
            "avatarURL": avatarURL ?? "",
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(uid).setData(userData) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to save user data: \(error.localizedDescription)")
                return
            }
            
            // Успешная регистрация — переходим на главный экран
            let homeVC = TabBarController()
            self?.navigationController?.setViewControllers([homeVC], animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backTapped() {
        onBackTapped?()
//        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - PHPickerViewControllerDelegate
extension RegistrationController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self?.selectedImage = image
                    self?.avatarImageView.image = image
                }
            }
        }
    }
}
