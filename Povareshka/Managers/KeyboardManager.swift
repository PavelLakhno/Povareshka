//
//  KeyboardManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import UIKit

final class KeyboardManager {
    static func registerForKeyboardNotifications(observer: Any, showSelector: Selector, hideSelector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: showSelector, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(observer, selector: hideSelector, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    static func removeKeyboardNotifications(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(observer, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
