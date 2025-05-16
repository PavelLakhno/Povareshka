//
//  NewPasswordController.swift
//  Povareshka
//
//  Created by user on 16.05.2025.
//

import UIKit
import Auth

class NewPasswordController: UIViewController {
    var onRegisterTapped: (() -> Void)?
    var onResetPasswordTapped: (() -> Void)?
    
    // MARK: - UI Elements
    private let loginLabel: UILabel = {
        let lbl = UILabel()
        lbl.layer.cornerRadius = Resources.Sizes.cornerRadius
        lbl.textAlignment = .left
        lbl.backgroundColor = .neutral10
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let newPasswordTextField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = Resources.Sizes.cornerRadius
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
            string: Resources.Strings.Placeholders.password,
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = Resources.Sizes.cornerRadius
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
            string: Resources.Strings.Placeholders.password,
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private lazy var confirmPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Strings.Buttons.entrance, for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Resources.Sizes.cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(loginLabel)
        view.addSubview(newPasswordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(confirmPasswordButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            loginLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            loginLabel.bottomAnchor.constraint(equalTo: newPasswordTextField.topAnchor, constant: -Resources.Sizes.paddingHeight),
            loginLabel.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),
            
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            newPasswordTextField.bottomAnchor.constraint(equalTo: confirmPasswordTextField.topAnchor, constant: -Resources.Sizes.paddingHeight),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),

            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            confirmPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight),

            confirmPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            confirmPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            confirmPasswordButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: Resources.Sizes.paddingHeight),
            confirmPasswordButton.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight),
        ])
    }
    
    func updatePassword(newPassword: String) async throws {
        try await SupabaseManager.shared.client.auth.update(user: UserAttributes(password: newPassword))
    }
    
    @objc private func showPasswordReset() {
        onResetPasswordTapped?()
    }
    
    @objc private func signInTapped() {
        guard
            let email = loginTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            print("Заполните все поля")
            return
        }
        
        Task {
            do {
                let response = try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
                print("✅ Login completed:", response.user.email ?? "No email")
                
                (parent as? BaseAuthViewController)?.handleAuthSuccess()
            } catch {
                let authError: Resources.AuthError
                        
                        if let supabaseError = error as? Resources.AuthError {
                            // Ошибка от Supabase
                            authError = supabaseError
                        } else if let urlError = error as? URLError {
                            // Ошибка сети
                            authError = Resources.AuthError.networkError(urlError)
                        } else {
                            // Неизвестная ошибка
                            authError = Resources.AuthError.unknown(error)
                        }
                       
                        // Логируем полную ошибку для разработчика
                        print("🔴 Auth failed: \(authError.localizedDescription)")
                        
                        // Передаем обработанную ошибку в контроллер
                (parent as? BaseAuthViewController)?.handleAuthError(authError)
            }
        }
    }
    

}
