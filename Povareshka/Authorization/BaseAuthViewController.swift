//
//  BaseAuthViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 11.04.2025.
//

import UIKit

class BaseAuthViewController: UIViewController {
    // Общий фон
    private let backgroundImage: UIImageView = {
        let iv = UIImageView(image: Resources.Images.Background.meet)
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // Контейнер для форм
    private let containerView: UIView = {
        let view = UIView()
        
        view.isUserInteractionEnabled = true // Это критически важно
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
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            containerView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),
            
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
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
            loginVC.onRegisterTapped = { [weak self] in
                self?.showRegistrationForm()
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
    
    func showRegistrationForm() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.alpha = 0
        } completion: { _ in
            self.containerView.subviews.forEach { $0.removeFromSuperview() }
            
            let regVC = RegistrationController()
            regVC.onBackTapped = { [weak self] in
                self?.showLoginForm()
            }
            
            self.embedChild(regVC, in: self.containerView)
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
//    private func embedChild(_ child: UIViewController, in container: UIView) {
//        // Удаляем предыдущие
//        container.subviews.forEach { $0.removeFromSuperview() }
//        children.forEach { $0.removeFromParent() }
//        
//        // Добавляем новые
//        addChild(child)
//        container.addSubview(child.view)
//        child.view.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            child.view.topAnchor.constraint(equalTo: container.topAnchor),
//            child.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            child.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
//        ])
//        
//        child.didMove(toParent: self)
//        
//        // Принудительное обновление layout
//        container.layoutIfNeeded()
//    }
}
