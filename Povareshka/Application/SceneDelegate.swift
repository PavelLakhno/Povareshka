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
        window?.makeKeyAndVisible()
        checkAuthState()
                
        if let url = connectionOptions.urlContexts.first?.url {
            handleDeepLink(url)
        }
    }
    
    private func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        Task {
            do {
                try await SupabaseManager.shared.client.auth.session(from: url)
                // Показать экран ввода нового пароля
            } catch {
                print("Error handling password reset:", error)
            }
        }
    }

    private func checkAuthState() {
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                print("✅ Authorized user:", session.user.email ?? "No email")
                 showMainApp()
            } catch {
                print("❌ User is not authorized:", error.localizedDescription)
                showAuthScreen()
            }
        }
    }

    private func showMainApp() {
        let tabBarVC = TabBarController()
        UIView.transition(with: window!,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: {
            self.window?.rootViewController = tabBarVC
        })
    }

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
                self.showMainApp()
                
            } catch {
                print("❌ Error Deep Link:", error)
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


