//
//  AppCordinator.swift
//  Povareshka
//
//  Created by user on 20.05.2025.
//

import UIKit

final class AppCoordinator {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
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
                    await showResetPasswordScreen()
                } else {
                    await showMainApp()
                }
            } catch {
                print("❌ URL Handling Error:", error)
                await showAuthScreen()
            }
        }
    }
    
    // Проверка состояния авторизации
    private func checkAuthState() {
//        Task {
//            do {
//                let session = try await SupabaseManager.shared.client.auth.session
//                await showMainApp()
//            } catch {
//                await showAuthScreen()
//            }
//        }
        
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                await MainActor.run {
                    print("✅ Authorized user:", session.user.email ?? "No email")
                    showMainApp()
                }
            } catch {
                await MainActor.run {
                    print("❌ User is not authorized:", error.localizedDescription)
                    showAuthScreen()
                }
            }
        }
    }
    
    // Переход к основному потоку
    @MainActor
    private func showMainApp() {
        let tabBarVC = TabBarController()
        transitionToViewController(tabBarVC)
    }
    
    // Переход к экрану авторизации
    @MainActor
    private func showAuthScreen() {
        let authVC = BaseAuthViewController()
        transitionToViewController(authVC)
    }
    
    // Переход к сбросу пароля
    @MainActor
    private func showResetPasswordScreen() {
        let newPasswordVC = NewPasswordController()
        transitionToViewController(newPasswordVC)
    }
    
    // Анимированная смена rootViewController
    @MainActor
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
    
    // Проверка, является ли URL ссылкой на сброс пароля
    private func isPasswordResetURL(_ url: URL) -> Bool {
        url.absoluteString.contains("reset-password")
    }
}
