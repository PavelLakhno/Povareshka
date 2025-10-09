//
//  NewPasswordController.swift
//  Povareshka
//
//  Created by user on 16.05.2025.
//

import UIKit
import Auth

final class NewPasswordController: UIViewController {
    var onPasswordUpdateTapped: (() -> Void)?
    
    // MARK: - UI Elements
    
    private let loginLabel = UILabel(textAlignment: .center)

    private let newPasswordTextField = UITextField.configureTextField(
        placeholder: AppStrings.Placeholders.passwordNew,
        isSecureTextEntry: true,
        borderColor: .clear,
        backgroundColor: AppColors.gray100
    )

    private let confirmPasswordTextField = UITextField.configureTextField(
        placeholder: AppStrings.Placeholders.passwordRepeat,
        isSecureTextEntry: true,
        borderColor: .clear,
        backgroundColor: AppColors.gray100
    )

    private lazy var confirmPasswordButton = UIButton(
        title: AppStrings.Buttons.done,
        backgroundColor: AppColors.primaryOrange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(updatePasswordTapped)
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        getSession()
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        view.backgroundColor = .clear
        view.addSubview(loginLabel)
        view.addSubview(newPasswordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(confirmPasswordButton)
    }
    
    private func getSession() {
        Task {
            do {
                // Сначала пробуем стандартную обработку Supabase
                let session = try await SupabaseManager.shared.client.auth.session
                loginLabel.text = session.user.email
                // Определяем тип операции
                
            } catch {
                // Если стандартная обработка не сработала, пробуем кастомный парсинг
                AlertManager.shared.showError(on: self, error: error)
            }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            loginLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            loginLabel.bottomAnchor.constraint(equalTo: newPasswordTextField.topAnchor, constant: -Constants.paddingMedium),
            loginLabel.heightAnchor.constraint(equalToConstant: Constants.height),
            
            newPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            newPasswordTextField.bottomAnchor.constraint(equalTo: confirmPasswordTextField.topAnchor, constant: -Constants.paddingMedium),
            newPasswordTextField.heightAnchor.constraint(equalToConstant: Constants.height),

            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            confirmPasswordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: Constants.height),

            confirmPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            confirmPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            confirmPasswordButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: Constants.paddingMedium),
            confirmPasswordButton.heightAnchor.constraint(equalToConstant: Constants.height),
        ])
    }
    
    @objc private func showPasswordReset() {
        onPasswordUpdateTapped?()
    }
    
    @objc private func updatePasswordTapped() {
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            AlertManager.shared.show(on: self,
                                     title: AppStrings.Alerts.errorTitle,
                                     message: AppStrings.Messages.enterFields)
            return
        }
        
        guard newPassword == confirmPassword else {
            AlertManager.shared.show(on: self,
                                     title: AppStrings.Alerts.errorTitle,
                                     message: AppStrings.Messages.passwordMismatch)
            return
        }
        
        guard newPassword.count >= 6 else {
            AlertManager.shared.show(on: self,
                                     title: AppStrings.Alerts.errorTitle,
                                     message: AppStrings.Messages.passwordSixSigns)
            return
        }
        
        Task {
            do {
                // 1. Сначала получаем текущего пользователя
                let currentUser = try await SupabaseManager.shared.client.auth.session.user
                
                // 2. Проверяем recovery-сессию (новый правильный способ)
                guard let identities = currentUser.identities,
                      identities.contains(where: { $0.provider == "email" }) else {
                    throw PasswordResetError.invalidRecoverySession
                }
                
                // 3. Обновляем пароль
                try await SupabaseManager.shared.client.auth.update(user: UserAttributes(
                    password: newPassword
                ))
                
                // 4. После успешного обновления - разлогиниваем и логиним снова
                try await SupabaseManager.shared.client.auth.signOut()
                
                // 5. Логиним с новым паролем
                let _ = try await SupabaseManager.shared.client.auth.signIn(
                    email: currentUser.email ?? "",
                    password: newPassword
                )
                
                await MainActor.run {
                    (self.parent as? BaseAuthViewController)?.handleAuthSuccess()
                }
                
            } catch {
                await handlePasswordUpdateError(error)
            }
        }
 
    }

    private func handlePasswordUpdateError(_ error: Error) async {
        let errorMessage: String
        
        switch error {
        case let authError as AuthError where authError.localizedDescription.contains("different from the old"):
            errorMessage = "Новый пароль должен отличаться от старого"
            
        case is PasswordResetError:
            errorMessage = "Сессия восстановления недействительна. Запросите ссылку снова"
            
        case let urlError as URLError:
            errorMessage = "Ошибка сети. Проверьте подключение"
            print("Network error:", urlError)
            
        default:
            errorMessage = "Ошибка при обновлении пароля: \(error.localizedDescription)"
            print("Unknown error:", error)
        }
        
        await MainActor.run {
            let alert = UIAlertController(
                title: "Ошибка",
                message: errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    enum PasswordResetError: Error {
        case invalidRecoverySession
    }
}
