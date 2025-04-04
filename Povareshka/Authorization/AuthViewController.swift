//
//  AuthViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

import UIKit

class AuthViewController: UIViewController {
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
//        imageView.image = Resources.Images.Icons.profile // You'll need to add a logo image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        view.backgroundColor = UIColor(patternImage: Resources.Images.Background.start ?? UIImage())
        
        // Add subviews
        view.addSubview(logoImageView)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        view.addSubview(continueWithoutRegButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Logo constraints
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Sign in button constraints
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInButton.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -16),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Sign up button constraints
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.bottomAnchor.constraint(equalTo: continueWithoutRegButton.topAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Continue without registration button constraints
            continueWithoutRegButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueWithoutRegButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueWithoutRegButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            continueWithoutRegButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loadMainView(){
        let tabBar = TabBarController()
        tabBar.modalPresentationStyle = .fullScreen
        present(tabBar, animated: true)
    }
}
