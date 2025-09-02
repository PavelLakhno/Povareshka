//
//  AlertManager.swift
//  Povareshka
//
//  Created by user on 28.07.2025.
//

//import UIKit
//
//@MainActor
//final class AlertManager {
//    // MARK: - Singleton
//    static let shared = AlertManager()
//    
//    private init() {}
//    
//    // MARK: - Public Methods
//    
//    /// Показывает стандартный алерт с заголовком, сообщением и кнопкой "OK"
//    func showAlert(
//        on viewController: UIViewController,
//        title: String,
//        message: String,
//        completion: (() -> Void)? = nil
//    ) {
//        let alert = UIAlertController(
//            title: title,
//            message: message,
//            preferredStyle: .alert
//        )
//        alert.addAction(
//            UIAlertAction(
//                title: Resources.Strings.Buttons.ok,
//                style: .default,
//                handler: { _ in completion?() }
//            )
//        )
//        viewController.present(alert, animated: true)
//    }
//    
//    /// Показывает алерт для ошибок, включая обработку SupabaseError
//    func showError(
//        on viewController: UIViewController,
//        error: Error,
//        completion: (() -> Void)? = nil
//    ) {
//        let message: String
//        if let supabaseError = error as? Resources.SupabaseError {
//            message = supabaseError.localizedDescription
//        } else {
//            message = error.localizedDescription
//        }
//        
//        showAlert(
//            on: viewController,
//            title: Resources.Strings.Alerts.errorTitle,
//            message: message,
//            completion: completion
//        )
//    }
//    
//    /// Показывает алерт подтверждения удаления с кнопками "Удалить" и "Отмена"
//    func showDeleteConfirmation(
//        on viewController: UIViewController,
//        title: String = Resources.Strings.Alerts.deleteStepTitle,
//        message: String = Resources.Strings.Alerts.deleteStepMessage,
//        deleteHandler: @escaping () -> Void,
//        cancelHandler: (() -> Void)? = nil
//    ) {
//        let alert = UIAlertController(
//            title: title,
//            message: message,
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(
//            UIAlertAction(
//                title: Resources.Strings.Buttons.delete,
//                style: .destructive,
//                handler: { _ in deleteHandler() }
//            )
//        )
//        alert.addAction(
//            UIAlertAction(
//                title: Resources.Strings.Buttons.cancel,
//                style: .cancel,
//                handler: { _ in cancelHandler?() }
//            )
//        )
//        
//        viewController.present(alert, animated: true)
//    }
//}
import UIKit

@MainActor
final class AlertManager {
    // MARK: - Singleton
    static let shared = AlertManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Универсальный метод для показа алертов
    func show(
        on viewController: UIViewController,
        title: String,
        message: String,
        actions: [UIAlertAction]? = nil,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        // Если actions не предоставлены, используем стандартную кнопку OK
        if let actions = actions, !actions.isEmpty {
            actions.forEach { alert.addAction($0) }
        } else {
            alert.addAction(UIAlertAction(
                title: Resources.Strings.Buttons.ok,
                style: .default,
                handler: { _ in completion?() }
            ))
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Специализированный метод для ошибок
    func showError(
        on viewController: UIViewController,
        error: Error,
        completion: (() -> Void)? = nil
    ) {
        let message: String
        
        // Расширенная обработка ошибок
        switch error {
        case let supabaseError as Resources.SupabaseError:
            message = supabaseError.localizedDescription
        case let authError as Resources.AuthError:
            message = authError.localizedDescription
        case let urlError as URLError:
            message = urlError.localizedDescription
//            print("Network error: \(urlError.localizedDescription)")
        default:
            message = error.localizedDescription
        }
        
        show(
            on: viewController,
            title: Resources.Strings.Alerts.errorTitle,
            message: message,
            completion: completion
        )
    }
    
    /// Специализированный метод для подтверждения действий
    func showConfirmation(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = Resources.Strings.Buttons.delete,
        confirmStyle: UIAlertAction.Style = .destructive,
        confirmHandler: @escaping () -> Void,
        cancelTitle: String = Resources.Strings.Buttons.cancel,
        cancelHandler: (() -> Void)? = nil
    ) {
        let confirmAction = UIAlertAction(
            title: confirmTitle,
            style: confirmStyle,
            handler: { _ in confirmHandler() }
        )
        
        let cancelAction = UIAlertAction(
            title: cancelTitle,
            style: .cancel,
            handler: { _ in cancelHandler?() }
        )
        
        show(
            on: viewController,
            title: title,
            message: message,
            actions: [confirmAction, cancelAction]
        )
    }
    
    // MARK: - Convenience Methods
    
    /// Быстрый вызов для удаления (сохраняем обратную совместимость)
    func showDeleteConfirmation(
        on viewController: UIViewController,
        title: String = Resources.Strings.Alerts.deleteStepTitle,
        message: String = Resources.Strings.Alerts.deleteStepMessage,
        deleteHandler: @escaping () -> Void,
        cancelHandler: (() -> Void)? = nil
    ) {
        showConfirmation(
            on: viewController,
            title: title,
            message: message,
            confirmTitle: Resources.Strings.Buttons.delete,
            confirmStyle: .destructive,
            confirmHandler: deleteHandler,
            cancelTitle: Resources.Strings.Buttons.cancel,
            cancelHandler: cancelHandler
        )
    }
    
    /// Для успешных операций
    func showSuccess(
        on viewController: UIViewController,
        title: String = Resources.Strings.Alerts.successTitle,
        message: String,
        completion: (() -> Void)? = nil
    ) {
        show(
            on: viewController,
            title: title,
            message: message,
            completion: completion
        )
    }
}
