//
//  AuthViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

import UIKit

class AuthViewController: UIViewController {
    var onRegisterTapped: (() -> Void)?
    var onResetPasswordTapped: (() -> Void)?
    
    // MARK: - UI Elements
    private let loginTextField: UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = Resources.Sizes.cornerRadius
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
            string: Resources.Strings.Placeholders.login,
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private let passwordTextField: UITextField = {
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
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Strings.Buttons.entrance, for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Resources.Sizes.cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Strings.Buttons.reg, for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Resources.Sizes.cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(loadRegView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Resources.Strings.Buttons.forgetPassword, for: .normal)
        button.backgroundColor = Resources.Colors.orange.withAlphaComponent(0.2)
        button.setTitleColor(Resources.Colors.orange, for: .normal)
        button.layer.cornerRadius = Resources.Sizes.cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.addTarget(self, action: #selector(showPasswordReset), for: .touchUpInside)
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

        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(forgotPasswordButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            loginTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -Resources.Sizes.paddingHeight),
            loginTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),
            
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            passwordTextField.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -Resources.Sizes.paddingHeight),
            passwordTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),

            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight),

            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: Resources.Sizes.paddingHeight),
            signUpButton.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight),

            forgotPasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            forgotPasswordButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: Resources.Sizes.paddingHeight),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight)
        ])
    }

    @objc private func loadRegView(){
        onRegisterTapped?()
    }
    
    @objc private func showPasswordReset() {
        onResetPasswordTapped?()
    }
}
