//
//  AuthViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

import UIKit
import Auth

final class AuthViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var loginTextField = UITextField.configureTextField(
        placeholder: Resources.Strings.Placeholders.login,
        keyboardType: .emailAddress,
        borderColor: .clear,
        backgroundColor: Resources.Colors.backgroundLight
    )

    private lazy var passwordTextField = UITextField.configureTextField(
        placeholder: Resources.Strings.Placeholders.password,
        isSecureTextEntry: true,
        borderColor: .clear,
        backgroundColor: Resources.Colors.backgroundLight
    )

    private lazy var signInButton = UIButton(
        title: Resources.Strings.Buttons.entrance,
        backgroundColor: Resources.Colors.orange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(signInTapped)
    )

    private lazy var signUpButton = UIButton(
        title: Resources.Strings.Buttons.reg,
        backgroundColor: Resources.Colors.orange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(signUnTapped)
    )

    private lazy var forgotPasswordButton = UIButton(
        title: Resources.Strings.Buttons.passwordForget,
        backgroundColor: Resources.Colors.orange.withAlphaComponent(0.6),
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(showPasswordReset)
    )
    
    var onRegisterTapped: (() -> Void)?
    var onResetPasswordTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        view.backgroundColor = .clear

        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(forgotPasswordButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            loginTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -Constants.paddingMedium),
            loginTextField.heightAnchor.constraint(equalToConstant: Constants.height),
            
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            passwordTextField.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -Constants.paddingMedium),
            passwordTextField.heightAnchor.constraint(equalToConstant: Constants.height),

            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: Constants.height),

            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: Constants.paddingMedium),
            signUpButton.heightAnchor.constraint(equalToConstant: Constants.height),

            forgotPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            forgotPasswordButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: Constants.paddingMedium),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: Constants.height)
        ])
    }

    @objc private func loadRegView(){
        onRegisterTapped?()
    }
    
    @objc private func showPasswordReset() {
        onResetPasswordTapped?()
    }
    
    @objc private func signInTapped() {
        guard
            let email = loginTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            AlertManager.shared.show(on: self,
                                     title: Resources.Strings.Alerts.errorTitle,
                                     message: Resources.Strings.Messages.enterFields)
            return
        }
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
//                AlertManager.shared.showSuccess(on: self, message: "✅ Login completed: \(response.user.email ?? "No email")")
//                print("✅ Login completed:", response.user.email ?? "No email")
                
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
//                AlertManager.shared.showError(on: self, error: authError)
//                        print("🔴 Auth failed: \(authError.localizedDescription)")
                        
                        // Передаем обработанную ошибку в контроллер
                (parent as? BaseAuthViewController)?.handleAuthError(authError)
            }
        }
    }
    
    @objc private func signUnTapped() {
        guard
            let email = loginTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            AlertManager.shared.show(on: self,
                                     title: Resources.Strings.Alerts.errorTitle,
                                     message: Resources.Strings.Messages.enterFields)
            return
        }
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
                
                (parent as? BaseAuthViewController)?.handleAuthSuccess()
            } catch {
                let authError: Resources.AuthError
                
                if let supabaseError = error as? Resources.AuthError {
                    // Supabase error
                    authError = supabaseError
                } else if let urlError = error as? URLError {
                    authError = Resources.AuthError.networkError(urlError)
                } else {
                    authError = Resources.AuthError.unknown(error)
                }
                (parent as? BaseAuthViewController)?.handleAuthError(authError)
            }
        }
    }
}
