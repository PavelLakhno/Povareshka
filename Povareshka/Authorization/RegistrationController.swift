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
    //    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
//    private let backButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitleColor(.orange, for: .normal)
//        btn.setTitle("← Назад", for: .normal)
//        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        return btn
//    }()
    
    
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
    
//    private let genderSegmentedControl = UISegmentedControl(items: ["Муж", "Жен"])
    private let genderSegmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Муж", "Жен"])
        segmentControl.layer.cornerRadius = 12
        segmentControl.selectedSegmentIndex = 0
        segmentControl.selectedSegmentTintColor = Resources.Colors.orange.withAlphaComponent(0.9)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentControl
    }()
    private let avatarImageView = UIImageView()
    private let selectPhotoButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    
    private var selectedImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
    }
    private func setupNavigationBar() {
//         1. Показываем навигационную панель
        navigationController?.navigationBar.isHidden = false
        
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
        view.backgroundColor = .clear //UIColor(patternImage: Resources.Images.Background.meet ?? UIImage())
        view.addSubview(contentView)
        
        // Avatar Image
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.masksToBounds = true
        avatarImageView.tintColor = Resources.Colors.orange
        avatarImageView.image = UIImage(systemName: "person.circle")
//        contentView.addSubview(backButton)
        contentView.addSubview(avatarImageView)
        
        // Select Photo Button
        selectPhotoButton.setTitle("Выбрать фото", for: .normal)
        selectPhotoButton.tintColor = Resources.Colors.orange
        selectPhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        contentView.addSubview(selectPhotoButton)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(phoneTextField)
        contentView.addSubview(passwordTextField)
        
        // Gender Segmented Control
//        genderSegmentedControl.selectedSegmentIndex = 0
//        genderSegmentedControl.backgroundColor = Resources.Colors.orange
//        genderSegmentedControl.selectedSegmentTintColor = Resources.Colors.orange.withAlphaComponent(0.8)
//        genderSegmentedControl.tintColor = .gray
        contentView.addSubview(genderSegmentedControl)
        
        // Register Button
        registerButton.setTitle("Регистрация", for: .normal)
        registerButton.backgroundColor = Resources.Colors.orange
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 12
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        contentView.addSubview(registerButton)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        let padding: CGFloat = 20
        let textFieldHeight: CGFloat = 44
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        selectPhotoButton.translatesAutoresizingMaskIntoConstraints = false
//        nameTextField.translatesAutoresizingMaskIntoConstraints = false
//        emailTextField.translatesAutoresizingMaskIntoConstraints = false
//        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
//        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
//        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
//            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
//            backButton.bottomAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: padding*2),
            
            avatarImageView.bottomAnchor.constraint(equalTo: selectPhotoButton.topAnchor, constant: -8),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            selectPhotoButton.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -8),
            selectPhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTextField.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -padding),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            nameTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            emailTextField.bottomAnchor.constraint(equalTo: phoneTextField.topAnchor, constant: -padding),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            phoneTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            phoneTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            passwordTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: padding),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            genderSegmentedControl.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            registerButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: padding),
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            registerButton.heightAnchor.constraint(equalToConstant: textFieldHeight),
//            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
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
