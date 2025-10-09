//
//  PasswordResetController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.04.2025.
//

import UIKit
//import FirebaseAuth

final class PasswordResetController: UIViewController {
    var onBackTapped: (() -> Void)?
    // MARK: - UI Elements
    private lazy var emailTextField = UITextField.configureTextField(
        placeholder: AppStrings.Placeholders.enterEmail,
        keyboardType: .emailAddress,
        borderColor: .clear,
        backgroundColor: AppColors.gray100
    )

    private lazy var resetButton = UIButton(
        title: AppStrings.Buttons.passwordReset,
        backgroundColor: AppColors.primaryOrange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(handleReset)
    )

    private lazy var backButton = UIButton(
        title: AppStrings.Buttons.back,
        image: AppImages.Icons.back,
        tintColor: AppColors.primaryOrange,
        titleColor: AppColors.primaryOrange,
        target: self,
        action: #selector(backTapped)
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    private func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(backButton)
        view.addSubview(emailTextField)
        view.addSubview(resetButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.paddingMedium*4),
            
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            emailTextField.heightAnchor.constraint(equalToConstant: Constants.height),
            
            resetButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: Constants.paddingMedium),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            resetButton.heightAnchor.constraint(equalToConstant: Constants.height)
        ])
    }
    
    // MARK: - Actions
    @objc private func handleReset() {
        guard let email = emailTextField.text, !email.isEmpty else {
//            showAlert(title: Resources.Strings.Titles.error,
//                      message: Resources.Strings.Messages.enterEmail)
            AlertManager.shared.show(on: self,
                                          title: AppStrings.Titles.error,
                                          message: AppStrings.Messages.enterEmail)
            return
        }
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.resetPasswordForEmail(
                    email, redirectTo: URL(string: Config.supabaseRedirect)!
                )
                
                DispatchQueue.main.async {
                    AlertManager.shared.show(
                        on: self,
                        title: AppStrings.Titles.success,
                        message: "Password reset link sent to \(email)"
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.shared.showError(on: self, error: error)
                }
            }
        }
    }
    
    @objc private func backTapped() {
        onBackTapped?()
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onBackTapped?()
            completion?()
        })
        present(alert, animated: true)
    }
}
