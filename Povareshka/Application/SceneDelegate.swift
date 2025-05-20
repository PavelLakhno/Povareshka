//
//  SceneDelegate.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Настройка окна
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        
        // Создаем координатор
        guard let window = window else { return }
        appCoordinator = AppCoordinator(window: window)
        
        // Обработка URL (если приложение запущено по ссылке)
        if let url = connectionOptions.urlContexts.first?.url {
            appCoordinator?.handleIncomingURL(url)
        } else {
            appCoordinator?.start() // Стандартный запуск
        }
    }
    
    // Обработка Deep Links (если приложение уже запущено)
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        appCoordinator?.handleIncomingURL(url)
    }
}

//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    
//    var window: UIWindow?
//    
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        setupWindow(windowScene: windowScene)
//        
//        if let url = connectionOptions.urlContexts.first?.url {
//            handleIncomingURL(url)
//        } else {
//            checkAuthState()
//        }
//    }
//    
//    private func setupWindow(windowScene: UIWindowScene) {
//        window = UIWindow(windowScene: windowScene)
//        window?.makeKeyAndVisible()
//        window?.rootViewController = MainViewController() // Или LaunchViewController
//    }
//    
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        handleIncomingURL(url)
//    }
//}
//
//// MARK: - Auth State Management
//extension SceneDelegate {
//    private func checkAuthState() {
//        Task {
//            do {
//                let session = try await SupabaseManager.shared.client.auth.session
//                await MainActor.run {
//                    print("✅ Authorized user:", session.user.email ?? "No email")
//                    showMainApp()
//                }
//            } catch {
//                await MainActor.run {
//                    print("❌ User is not authorized:", error.localizedDescription)
//                    showAuthScreen()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - URL Handling
//extension SceneDelegate {
//    private func handleIncomingURL(_ url: URL) {
//        print("🔗 Handling URL:", url.absoluteString)
//
//        Task {
//            do {
//                // Сначала пробуем стандартную обработку Supabase
//                try await SupabaseManager.shared.client.auth.session(from: url)
//                // Определяем тип операции
//                if isPasswordResetURL(url) {
//                    await MainActor.run {
//                        print("Password reset link processed")
//                        showResetPasswordScreen()
//                    }
//                } else {
//                    await MainActor.run {
//                        print("Auth link processed")
//                        showMainApp()
//                    }
//                }
//            } catch {
//                print("❌ Error Deep Link:", error)
//            }
//        }
//    }
//    
//    private func isPasswordResetURL(_ url: URL) -> Bool {
//        return url.absoluteString.contains("reset-password")
//    }
//    
//    private func showError(message: String) async {
//        await MainActor.run {
//            let alert = UIAlertController(
//                title: "Error",
//                message: message,
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            window?.rootViewController?.present(alert, animated: true)
//            checkAuthState()
//        }
//    }
//}
//
//// MARK: - Navigation
//extension SceneDelegate {
//    private func showMainApp() {
//        let tabBarVC = TabBarController()
//        transitionToViewController(tabBarVC)
//    }
//    
//    private func showAuthScreen() {
//        let authVC = BaseAuthViewController()
//        transitionToViewController(authVC)
//    }
//    
//    private func showResetPasswordScreen() {
//        let newPasswordVC = NewPasswordController()
//        transitionToViewController(newPasswordVC)
//    }
//    
//    private func transitionToViewController(_ viewController: UIViewController) {
//        guard let window = window else { return }
//        
//        UIView.transition(with: window,
//                         duration: 0.3,
//                         options: .transitionCrossDissolve,
//                         animations: {
//            window.rootViewController = viewController
//        })
//    }
//}


//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        setupWindow(windowScene: windowScene)
//
//        // Обработка deep link при запуске
//        if let url = connectionOptions.urlContexts.first?.url {
//            handleIncomingURL(url)
//        } else {
//            checkAuthState()
//        }
//    }
//
//    private func setupWindow(windowScene: UIWindowScene) {
//        window = UIWindow(windowScene: windowScene)
//        window?.makeKeyAndVisible()
//        // Временно показываем launch screen
//        window?.rootViewController = MainViewController()
//    }
//
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        handleIncomingURL(url)
//    }
//}
//
//// MARK: - Auth State Management
//extension SceneDelegate {
//    private func checkAuthState() {
//        Task {
//            do {
//                let session = try await SupabaseManager.shared.client.auth.session
//                await MainActor.run {
//                    print("✅ Authorized user:", session.user.email ?? "No email")
//                    showMainApp()
//                }
//            } catch {
//                await MainActor.run {
//                    print("❌ User is not authorized:", error.localizedDescription)
//                    showAuthScreen()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Deep Link Handling
//extension SceneDelegate {
//    private func handleIncomingURL(_ url: URL) {
//        print("Handling incoming URL:", url.absoluteString)
//
//        Task {
//            do {
//                if isPasswordResetURL(url) {
//                    try await handlePasswordReset(url: url)
//                } else {
//                    try await handleAuthDeepLink(url: url)
//                }
//            } catch {
//                await MainActor.run {
//                    print("❌ Deep Link Error:", error)
//                    showErrorAlert(error: error)
//                    // Если не получилось обработать ссылку, показываем стандартный экран
//                    checkAuthState()
//                }
//            }
//        }
//    }
//
//    private func isPasswordResetURL(_ url: URL) -> Bool {
//        return url.absoluteString.contains("type=recovery") || url.fragment?.contains("type=recovery") == true
//    }
//
//    private func handlePasswordReset(url: URL) async throws {
//        // Обрабатываем ссылку сброса пароля
//        try await SupabaseManager.shared.client.auth.session(from: url)
//
//        await MainActor.run {
//            print("Password reset link processed successfully")
//            showResetPasswordScreen()
//        }
//    }
//
//    private func handleAuthDeepLink(url: URL) async throws {
//        let (accessToken, refreshToken) = try extractTokensFromURL(url)
//        try await SupabaseManager.shared.client.auth.setSession(
//            accessToken: accessToken,
//            refreshToken: refreshToken
//        )
//
//        await MainActor.run {
//            print("Auth deep link processed successfully")
//            showMainApp()
//        }
//    }
//
//    private func extractTokensFromURL(_ url: URL) throws -> (accessToken: String, refreshToken: String) {
//        guard let fragment = url.fragment else {
//            throw AuthError.invalidURLFormat
//        }
//
//        let components = fragment.components(separatedBy: "&")
//
//        guard let accessTokenComponent = components.first(where: { $0.starts(with: "access_token=") }),
//              let refreshTokenComponent = components.first(where: { $0.starts(with: "refresh_token=") }) else {
//            throw AuthError.tokensNotFound
//        }
//
//        let accessToken = String(accessTokenComponent.dropFirst("access_token=".count))
//        let refreshToken = String(refreshTokenComponent.dropFirst("refresh_token=".count))
//
//        guard !accessToken.isEmpty, !refreshToken.isEmpty else {
//            throw AuthError.emptyTokens
//        }
//
//        return (accessToken, refreshToken)
//    }
//}
//
//// MARK: - Navigation
//extension SceneDelegate {
//    private func showMainApp() {
//        let tabBarVC = TabBarController()
//        transitionToViewController(tabBarVC)
//    }
//
//    private func showAuthScreen() {
//        let authVC = BaseAuthViewController()
//        transitionToViewController(authVC)
//    }
//
//    private func showResetPasswordScreen() {
//        let newPasswordVC = NewPasswordController()
//        transitionToViewController(newPasswordVC)
//    }
//
//    private func transitionToViewController(_ viewController: UIViewController) {
//        guard let window = self.window else { return }
//
//        UIView.transition(with: window,
//                          duration: 0.3,
//                          options: .transitionCrossDissolve,
//                          animations: {
//            window.rootViewController = viewController
//        })
//    }
//
//    private func showErrorAlert(error: Error) {
//        let alert = UIAlertController(
//            title: "Error",
//            message: error.localizedDescription,
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
////        print(error.localizedDescription)
//
//        window?.rootViewController?.present(alert, animated: true)
//    }
//}
//
//// MARK: - Auth Errors
//enum AuthError: Error, LocalizedError {
//    case invalidURLFormat
//    case tokensNotFound
//    case emptyTokens
//
//    var errorDescription: String? {
//        switch self {
//        case .invalidURLFormat:
//            print( "Invalid URL format")
//            return "Invalid URL format"
//        case .tokensNotFound:
//            print("Authentication tokens not found in URL")
//            return "Authentication tokens not found in URL"
//        case .emptyTokens:
//            print("Received empty authentication tokens")
//            return "Received empty authentication tokens"
//        }
//    }
//}


//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(windowScene: windowScene)
//        window?.makeKeyAndVisible()
//        checkAuthState()
//
//        if let url = connectionOptions.urlContexts.first?.url {
//            handleDeepLink(url)
//        }
//    }
//
//
//    private func checkAuthState() {
//        Task {
//            do {
//                let session = try await SupabaseManager.shared.client.auth.session
//                print("✅ Authorized user:", session.user.email ?? "No email")
//                 showMainApp()
//            } catch {
//                print("❌ User is not authorized:", error.localizedDescription)
//                showAuthScreen()
//            }
//        }
//    }
//
//    private func showMainApp() {
//        let tabBarVC = TabBarController()
//        UIView.transition(with: window!,
//                        duration: 0.3,
//                        options: .transitionCrossDissolve,
//                        animations: {
//            self.window?.rootViewController = tabBarVC
//        })
//    }
//
//    private func showAuthScreen() {
//        let authVC = BaseAuthViewController()
//        UIView.transition(with: window!,
//                        duration: 0.3,
//                        options: .transitionCrossDissolve,
//                        animations: {
//            self.window?.rootViewController = authVC
//        })
//    }
//
//    private func showResetPasswordScreen() {
//        let newPasswordVC = NewPasswordController()
//        UIView.transition(with: window!,
//                        duration: 0.3,
//                        options: .transitionCrossDissolve,
//                        animations: {
//            self.window?.rootViewController = newPasswordVC
//        })
//    }
//
//    internal func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        handleDeepLink(url)
//    }
//
//    private func handleDeepLink(_ url: URL) {
//        Task {
//            do {
//                let (accessToken, refreshToken) = try extractTokensFromURL(url)
//                try await SupabaseManager.shared.client.auth.setSession(
//                    accessToken: accessToken,
//                    refreshToken: refreshToken
//                )
//                self.showMainApp()
//
//            } catch {
//                print("❌ Error Deep Link:", error)
//            }
//        }
//    }
//
//    private func extractTokensFromURL(_ url: URL) throws -> (accessToken: String, refreshToken: String) {
//        guard let fragment = url.fragment else {
//            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Incorrect URL format"])
//        }
//
//        let components = fragment.components(separatedBy: "&")
//        guard let accessToken = components.first(where: { $0.starts(with: "access_token=") })?.dropFirst("access_token=".count),
//              let refreshToken = components.first(where: { $0.starts(with: "refresh_token=") })?.dropFirst("refresh_token=".count) else {
//            throw NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Tokens not found in URL"])
//        }
//
//        return (String(accessToken), String(refreshToken))
//    }
//}
