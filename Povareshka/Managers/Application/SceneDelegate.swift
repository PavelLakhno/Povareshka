//
//  SceneDelegate.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
//        window?.rootViewController = LoadingViewController()
        window?.makeKeyAndVisible()
        
//        checkAuthState()
        Task {
            await checkAuthState()
        }
                
        if let url = connectionOptions.urlContexts.first?.url {
            handleDeepLink(url)
        }
    }
    
//    private func checkAuthState() {
//        Task {
//            if await SupabaseManager.shared.isSessionValid() {
//                showMainApp()
//            } else {
//                showAuthScreen()
//            }
//        }
//    }
    
    private func checkAuthState() async {
        let isValid = await SupabaseManager.shared.isSessionValid()
        
        await MainActor.run {
            if isValid {
                showMainApp()
            } else {
                showAuthScreen()
            }
        }
    }

    @MainActor
    private func showMainApp() {
        let tabBarVC = TabBarController()
        UIView.transition(with: window!,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: {
            self.window?.rootViewController = tabBarVC
        })
    }
    
    @MainActor
    private func showAuthScreen() {
        let authVC = BaseAuthViewController()
        UIView.transition(with: window!,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: {
            self.window?.rootViewController = authVC
        })
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url)
    }
    
    private func handleDeepLink(_ url: URL) {
        Task {
            do {
                let (accessToken, refreshToken) = try extractTokensFromURL(url)
                try await SupabaseManager.shared.client.auth.setSession(
                    accessToken: accessToken,
                    refreshToken: refreshToken
                )
                await MainActor.run {
                    self.showMainApp()
                }
                
            } catch {
                print("Deep Link error:", error)
                await MainActor.run {
                    self.showAuthScreen()
                }
                
            }
        }
    }
    
    private func extractTokensFromURL(_ url: URL) throws -> (accessToken: String, refreshToken: String) {
        guard let fragment = url.fragment else {
            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Incorrect URL format"])
        }
        
        let components = fragment.components(separatedBy: "&")
        guard let accessToken = components.first(where: { $0.starts(with: "access_token=") })?.dropFirst("access_token=".count),
              let refreshToken = components.first(where: { $0.starts(with: "refresh_token=") })?.dropFirst("refresh_token=".count) else {
            throw NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Tokens not found in URL"])
        }
        
        return (String(accessToken), String(refreshToken))
    }
}

//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    
//    var window: UIWindow?
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        window = UIWindow(windowScene: windowScene)
//        
//        // Проверяем авторизацию при запуске
//        Task {
//            await checkAuthState()
//        }
//        window?.makeKeyAndVisible()
//        
//        // Обработка deep link
//        if let url = connectionOptions.urlContexts.first?.url {
//            print(url)
//            handleDeepLink(url)
//        }
//    
//    }
//    
//    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
//        guard let url = URLContexts.first?.url else { return }
//        handleDeepLink(url)
//    }
//    
//    @MainActor
//    private func handleDeepLink(_ url: URL) {
//        Task {
//            do {
//                let (accessToken, refreshToken) = try extractTokensFromURL(url)
//                try await SupabaseManager.shared.client.auth.setSession(
//                    accessToken: accessToken,
//                    refreshToken: refreshToken
//                )
//                
//                // После успешной авторизации через deep link
//                await MainActor.run {
//                    let tabBarVC = TabBarController()
//                    window?.rootViewController = tabBarVC
//                }
//                
//            } catch {
//                print("Deep Link error:", error)
//            }
//        }
//    }
//    
//    private func extractTokensFromURL(_ url: URL) throws -> (accessToken: String, refreshToken: String) {
//        guard let fragment = url.fragment else {
//            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Incorrect format URL"])
//        }
//        
//        var accessToken: String?
//        var refreshToken: String?
//        
//        let components = fragment.components(separatedBy: "&")
//        for component in components {
//            if component.starts(with: "access_token=") {
//                accessToken = String(component.dropFirst("access_token=".count))
//            } else if component.starts(with: "refresh_token=") {
//                refreshToken = String(component.dropFirst("refresh_token=".count))
//            }
//        }
//        
//        guard let accessToken = accessToken, let refreshToken = refreshToken else {
//            throw NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Tokens not found in URL"])
//        }
//        
//        return (accessToken, refreshToken)
//    }
//    
// 
//    private func checkAuthState() async {
//        do {
//            // 1. Пытаемся получить текущего пользователя
//            let user = try await SupabaseManager.shared.client.auth.session
//            
//            // 2. Если успешно - переходим на главный экран
//            await MainActor.run {
//                let tabBarVC = TabBarController()
//                window?.rootViewController = tabBarVC
//            }
//            
//        } catch {
//            // 3. Если ошибка - пробуем обновить сессию
//            do {
//                try await SupabaseManager.shared.client.auth.refreshSession()
//                
//                // 4. Если обновление успешно - переходим на главный экран
//                await MainActor.run {
//                    let tabBarVC = TabBarController()
//                    window?.rootViewController = tabBarVC
//                }
//                
//            } catch {
//                // 5. Если обновление не удалось - показываем экран авторизации
//                await MainActor.run {
//                    let authVC = BaseAuthViewController()
//                    window?.rootViewController = authVC
//                }
//            }
//        }
//    }
//}
