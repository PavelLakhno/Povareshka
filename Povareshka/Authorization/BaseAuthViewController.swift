//
//  BaseAuthViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 11.04.2025.
//

import UIKit

class BaseAuthViewController: UIViewController {
    // General background
    private let backgroundImage: UIImageView = {
        let iv = UIImageView(image: Resources.Images.Background.meet)
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Container for forms
    private let containerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showLoginForm()
    }

    private func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Resources.Sizes.paddingWidth),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Resources.Sizes.paddingWidth),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // Переключение между формами
    func showLoginForm() {
        // Анимация исчезновения текущей формы

        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0
        } completion: { [unowned self] _ in
            // Удаляем текущие subviews
            containerView.subviews.forEach { $0.removeFromSuperview() }

            // Создаем и настраиваем LoginViewController
            let loginVC = AuthViewController()
         
            loginVC.onResetPasswordTapped = { [weak self] in
                self?.showPasswordResetForm()
            }

            // Добавляем новую форму (пока невидимую)
            embedChild(loginVC, in: containerView)
            containerView.alpha = 0

            // Анимация появления новой формы
            UIView.animate(withDuration: 0.3) {
                self.containerView.alpha = 1
            }
        }
    }
    
   
    func showPasswordResetForm() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0
        } completion: { _ in
            self.containerView.subviews.forEach { $0.removeFromSuperview() }
            
            let resetVC = PasswordResetController()
            resetVC.onBackTapped = { [weak self] in
                self?.showLoginForm()
            }
            
            self.embedChild(resetVC, in: self.containerView)
            self.containerView.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.containerView.alpha = 1
            }
        }
    }
    
    func showPasswordUpdateFormDirectly() {
        // Пропускаем анимацию fade-in/fade-out при первом открытии
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        let updateVC = NewPasswordController()
        updateVC.onPasswordUpdateTapped = { [weak self] in
            self?.showLoginForm()
        }
        
        embedChild(updateVC, in: containerView)
        containerView.alpha = 1.0 // Уже видимый
    }
    
    func showPasswordUpdateForm() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0
        } completion: { _ in
            self.containerView.subviews.forEach { $0.removeFromSuperview() }
            
            let updateVC = NewPasswordController()
            updateVC.onPasswordUpdateTapped = { [weak self] in
                self?.showLoginForm()
            }
            
            self.embedChild(updateVC, in: self.containerView)
            self.containerView.alpha = 0
            
            UIView.animate(withDuration: 0.3) {
                self.containerView.alpha = 1
            }
        }
    }
    
    private func embedChild(_ child: UIViewController, in container: UIView) {
        addChild(child)
        container.addSubview(child.view)
        child.view.frame = container.bounds
        child.didMove(toParent: self)
    }
    
    func handleAuthSuccess() {
        DispatchQueue.main.async {
            // Полностью заменяем rootViewController вместо present
            if let window = self.view.window {
                let tabBarVC = TabBarController()
                window.rootViewController = tabBarVC
            }
        }
    }
    
    func handleAuthError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Ошибка",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
