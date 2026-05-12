//
//  AppCordinator.swift
//  Povareshka
//
//  Created by user on 20.05.2025.
//

import UIKit

@MainActor
final class AppCoordinator {
    
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        setupObservers()
    }
    
    // Запуск приложения (проверка авторизации)
    func start() {
        checkAuthState()
    }
    
    // Обработка URL (Deep Links)
    func handleIncomingURL(_ url: URL) {
        Task {
            do {
                try await SupabaseManager.shared.client.auth.session(from: url)
                if isPasswordResetURL(url) {
                    await MainActor.run { showResetPasswordScreen() }
                } else {
                    await MainActor.run { showMainApp() }
                }
            } catch {
#if DEBUG
                print("❌ Error Deep Link:", error)
#endif
            }
        }
    }

    private func checkAuthState() {
        Task {
            do {
                _ = try await SupabaseManager.shared.client.auth.session
                await MainActor.run { showMainApp() }
            } catch {
                await MainActor.run { showAuthScreen() }
            }
        }
    }
    
    private func isPasswordResetURL(_ url: URL) -> Bool {
        url.absoluteString.contains("reset-password")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@MainActor
extension AppCoordinator {
    
    private func showMainApp() {
        let tabBarVC = TabBarController()
        transitionToViewController(tabBarVC)
    }
    
    
    private func showAuthScreen() {
        let authVC = BaseAuthViewController()
        transitionToViewController(authVC)
    }

    private func showResetPasswordScreen() {
        // Создаем BaseAuthViewController и сразу показываем в нем форму сброса пароля
        let baseAuthVC = BaseAuthViewController()
        baseAuthVC.showPasswordUpdateForm() // Показываем форму обновления пароля
        transitionToViewController(baseAuthVC)
    }
    
    private func transitionToViewController(_ viewController: UIViewController) {
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.window.rootViewController = viewController
            }
        )
    }
  
}

extension AppCoordinator {
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .userDidLogout,
            object: nil
        )
    }
    
    @objc private func handleLogout() {
        showAuthScreen()
    }
    

}
