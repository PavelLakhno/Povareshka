//
//  SceneDelegate.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        if Auth.auth().currentUser != nil {
            // Пользователь авторизован — показываем основной интерфейс
            let tabBar = TabBarController()
            window?.rootViewController = UINavigationController(rootViewController: tabBar)
        } else {
            // Пользователь не авторизован — показываем экран входа
            let authVC = BaseAuthViewController()
            let navController = UINavigationController(rootViewController: authVC)
//            navController.navigationBar.isHidden = true
            window?.rootViewController = navController
        }

        window?.makeKeyAndVisible()
    }
}

