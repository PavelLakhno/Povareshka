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
        placeholder: AppStrings.Placeholders.login,
        keyboardType: .emailAddress,
        borderColor: .clear,
        backgroundColor: AppColors.gray100
    )

    private lazy var passwordTextField = UITextField.configureTextField(
        placeholder: AppStrings.Placeholders.password,
        isSecureTextEntry: true,
        borderColor: .clear,
        backgroundColor: AppColors.gray100
    )

    private lazy var signInButton = UIButton(
        title: AppStrings.Buttons.entrance,
        backgroundColor: AppColors.primaryOrange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(signInTapped)
    )

    private lazy var signUpButton = UIButton(
        title: AppStrings.Buttons.reg,
        backgroundColor: AppColors.primaryOrange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(signUnTapped)
    )

    private lazy var forgotPasswordButton = UIButton(
        title: AppStrings.Buttons.passwordForget,
        backgroundColor: AppColors.primaryOrange.withAlphaComponent(0.6),
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
                                     title: AppStrings.Alerts.errorTitle,
                                     message: AppStrings.Messages.enterFields)
            return
        }
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signIn(email: email, password: password)
                
                (parent as? BaseAuthViewController)?.handleAuthSuccess()
            } catch {

                let appError = mapToAppError(error)
                AlertManager.shared.showError(on: self, error: appError)
                (parent as? BaseAuthViewController)?.handleAuthError(appError)
            }
        }
    }
    
    @objc private func signUnTapped() {
        guard
            let email = loginTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            AlertManager.shared.show(on: self,
                                     title: AppStrings.Alerts.errorTitle,
                                     message: AppStrings.Messages.enterFields)
            return
        }
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signUp(email: email, password: password)
                
                (parent as? BaseAuthViewController)?.handleAuthSuccess()
            } catch {
                let appError = mapToAppError(error)
                AlertManager.shared.showError(on: self, error: appError)
                (parent as? BaseAuthViewController)?.handleAuthError(appError)
            }
        }
    }
    
    // MARK: - Error Mapping
    private func mapToAppError(_ error: Error) -> AppError {
        // Преобразуем ошибки Supabase Auth в наши доменные ошибки
        let errorMessage = error.localizedDescription.lowercased()
        
        if errorMessage.contains("invalid login credentials") {
            return AuthError.invalidCredentials
        } else if errorMessage.contains("email not confirmed") {
            return AuthError.emailNotVerified
        } else if errorMessage.contains("too many requests") {
            return AuthError.tooManyRequests
        } else if let _ = error as? URLError {
            return DataError.networkUnavailable
        }
        
        // Для неизвестных ошибок используем DataError с описанием
        return DataError.operationFailed(description: error.localizedDescription)
    }
}
