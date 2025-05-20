//
//  NewPasswordController.swift
//  Povareshka
//
//  Created by user on 16.05.2025.
//

import UIKit
import Auth

class NewPasswordController: UIViewController {
//    var onRegisterTapped: (() -> Void)?
    var onPasswordUpdateTapped: (() -> Void)?
    
    // MARK: - UI Elements
    private let loginLabel: UILabel = {
        let lbl = UILabel()
        lbl.layer.cornerRadius = Resources.Sizes.cornerRadius
        lbl.layer.masksToBounds = true
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
            string: "Новый пароль",
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
            string: "Повторите новый пароль",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private lazy var confirmPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Strings.Buttons.done, for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Resources.Sizes.cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(updatePasswordTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        getSession()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
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
                print("❌ Error Deep Link:", error)
            }
        }
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
    
    @objc private func showPasswordReset() {
        onPasswordUpdateTapped?()
    }
    
    @objc private func updatePasswordTapped() {
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Ошибка", message: "Заполните все поля")
            return
        }
        
        guard newPassword == confirmPassword else {
            showAlert(title: "Ошибка", message: "Пароли не совпадают")
            return
        }
        
        guard newPassword.count >= 6 else {
            showAlert(title: "Ошибка", message: "Пароль должен содержать минимум 6 символов")
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
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
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
