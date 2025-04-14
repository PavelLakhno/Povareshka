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

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Resources.Images.Icons.back, for: .normal)
        button.setTitle(Resources.Strings.Buttons.back, for: .normal)
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
            string: Resources.Strings.Placeholders.name,
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
            string: Resources.Strings.Placeholders.email,
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
            string: Resources.Strings.Placeholders.number,
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
            string: Resources.Strings.Placeholders.passwordReg,
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()

    private let genderSegmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: [Resources.Strings.Gender.man, Resources.Strings.Gender.woman])
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
        imageView.image = Resources.Images.Icons.avatar
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Strings.Buttons.addPhoto, for: .normal)
        button.tintColor = Resources.Colors.orange
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Strings.Buttons.reg, for: .normal)
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
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .clear

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
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Resources.Sizes.paddingWidth*4),
            
            avatarImageView.bottomAnchor.constraint(equalTo: selectPhotoButton.topAnchor, constant: -Resources.Sizes.paddingHeight),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Resources.Sizes.avatar),
            avatarImageView.heightAnchor.constraint(equalToConstant: Resources.Sizes.avatar),
            
            selectPhotoButton.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -Resources.Sizes.paddingHeight),
            selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameTextField.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -Resources.Sizes.paddingWidth),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            nameTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),
            
            emailTextField.bottomAnchor.constraint(equalTo: phoneTextField.topAnchor, constant: -Resources.Sizes.paddingWidth),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            emailTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),
            
            phoneTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            phoneTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            phoneTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            phoneTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),
            
            passwordTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: Resources.Sizes.paddingWidth),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            passwordTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: Resources.Sizes.paddingWidth),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            genderSegmentedControl.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight),
            
            registerButton.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: Resources.Sizes.paddingWidth),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            registerButton.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight),
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
            showAlert(title: Resources.Strings.Tittles.error, message: Resources.Strings.Messages.fieldsEmpty)
            return
        }
        
        let gender = genderSegmentedControl.selectedSegmentIndex == 0 ? Resources.Strings.Gender.man : Resources.Strings.Gender.woman
        
        // 1. Создаем пользователя в Firebase Auth (Email/Password)
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: Resources.Strings.Messages.regError, message: error.localizedDescription)
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
                print(Resources.Strings.Messages.uploadAvatarError, error)
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
                self?.showAlert(title: Resources.Strings.Tittles.error,
                                message: "\(Resources.Strings.Messages.failedSaveData) \(error.localizedDescription)")
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
