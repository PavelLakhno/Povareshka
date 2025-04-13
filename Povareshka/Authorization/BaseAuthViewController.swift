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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
//    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    private func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(containerView)

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
//            let regVC = RegistrationController()
//            regVC.onBackTapped = { [weak self] in
//                self?.navigationController?.popViewController(animated: true)
//            }
//            self.navigationController?.pushViewController(regVC, animated: true)
            
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

}
