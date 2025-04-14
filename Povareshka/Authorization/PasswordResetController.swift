//
//  PasswordResetController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.04.2025.
//

import UIKit
import FirebaseAuth

class PasswordResetController: UIViewController {
    var onBackTapped: (() -> Void)?
    // MARK: - UI Elements
    private let emailTextField: UITextField = {
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
            string: "Введите ваш email",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сбросить пароль", for: .normal)
        button.backgroundColor = Resources.Colors.orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Resources.Sizes.cornerRadius
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
//    private lazy var backButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Назад", for: .normal)
//        button.tintColor = Resources.Colors.orange
//        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Resources.Images.Icons.back, for: .normal)
        button.setTitle(Resources.Strings.Buttons.back, for: .normal)
        button.tintColor = Resources.Colors.orange
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
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
        
        view.addSubview(backButton)
        view.addSubview(emailTextField)
        view.addSubview(resetButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Resources.Sizes.paddingWidth*4),
            
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            emailTextField.heightAnchor.constraint(equalToConstant: Resources.Sizes.textFieldHeight),
            
            resetButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: Resources.Sizes.paddingHeight),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            resetButton.heightAnchor.constraint(equalToConstant: Resources.Sizes.buttonHeight)
        ])
    }
    
    // MARK: - Actions
    @objc private func handleReset() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: Resources.Strings.Tittles.error,
                      message: Resources.Strings.Messages.enterEmail)
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                self?.showAlert(title: Resources.Strings.Tittles.error,
                                message: error.localizedDescription)
                return
            }
            
            self?.showAlert(title: Resources.Strings.Tittles.success,
                            message: "\(Resources.Strings.Messages.letter) \(email)") {
                self?.backTapped()
            }
        }
    }
    
    @objc private func backTapped() {
        onBackTapped?()
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
