//
//  AuthViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

import UIKit

class AuthViewController: UIViewController {
    var onRegisterTapped: (() -> Void)?
    
    // MARK: - UI Elements
    let emailTextField: UITextField = {
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
            string: "Логин",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    let passwordTextField: UITextField = {
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
            string: "Пароль",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Регистрация", for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(loadRegView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let continueWithoutRegButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Продолжить без регистрации", for: .normal)
        button.backgroundColor = Resources.Colors.orange.withAlphaComponent(0.2)
        button.setTitleColor(Resources.Colors.orange, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.addTarget(self, action: #selector(loadMainView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .clear //UIColor(patternImage: Resources.Images.Background.meet ?? UIImage())
        
        // Add subviews
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(continueWithoutRegButton)
        
        let padding: CGFloat = 20
        let textFieldHeight: CGFloat = 44
        // Setup constraints
        NSLayoutConstraint.activate([
            
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            emailTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            passwordTextField.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -16),
            passwordTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            // Sign in button constraints
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            // Sign up button constraints
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            signUpButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),
            signUpButton.heightAnchor.constraint(equalToConstant: textFieldHeight),
            
            // Continue without registration button constraints
            continueWithoutRegButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            continueWithoutRegButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            continueWithoutRegButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 16),
            continueWithoutRegButton.heightAnchor.constraint(equalToConstant: textFieldHeight)
        ])
    }
    
    @objc private func loadMainView(){
        onRegisterTapped?()
        let tabBar = TabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
    
    @objc private func loadRegView(){
        onRegisterTapped?()
//        let regView = RegistrationController()
//        let navBar = NavBarController(rootViewController: regView)
//        navigationController?.pushViewController(regView, animated: true)
//        present(navBar, animated: true)
    }
    
//    @objc private func registerTapped() {
//        print("touch")
//        onRegisterTapped?()
//    }
    
}
