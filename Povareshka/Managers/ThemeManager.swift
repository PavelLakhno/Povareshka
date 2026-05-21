//
//  ThemeManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 20.05.2025.
//

import UIKit

@MainActor
final class ThemeManager {
    static let shared = ThemeManager()
    private let key = "isDarkTheme"

    private init() {}

    var isDarkTheme: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }

    func applyTheme(to window: UIWindow?) {
        window?.overrideUserInterfaceStyle = isDarkTheme ? .dark : .light
    }

    func setTheme(isDark: Bool, window: UIWindow?) {
        isDarkTheme = isDark
        UIView.animate(withDuration: 0.3) {
            window?.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }
}
