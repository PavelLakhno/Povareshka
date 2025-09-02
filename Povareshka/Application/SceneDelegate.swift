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
