//
//  AlertManager.swift
//  Povareshka
//
//  Created by user on 28.07.2025.
//

import UIKit

@MainActor
final class AlertManager {
    // MARK: - Singleton
    static let shared = AlertManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Universal method
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

        if let actions = actions, !actions.isEmpty {
            actions.forEach { alert.addAction($0) }
        } else {
            alert.addAction(UIAlertAction(
                title: AppStrings.Buttons.ok,
                style: .default,
                handler: { _ in completion?() }
            ))
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    /// Special method for errors
    func showError(
        on viewController: UIViewController,
        error: Error,
        completion: (() -> Void)? = nil
    ) {
        let message: String

        switch error {
        case let dataError as DataError:
            message = dataError.userFriendlyMessage
        case let authError as AuthError:
            message = authError.userFriendlyMessage
        case let urlError as URLError:
            message = urlError.localizedDescription
        default:
            message = error.localizedDescription
        }
        
        show(
            on: viewController,
            title: AppStrings.Alerts.errorTitle,
            message: message,
            completion: completion
        )
    }
    
    /// Special method for confirm movements
    func showConfirmation(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = AppStrings.Buttons.delete,
        confirmStyle: UIAlertAction.Style = .destructive,
        confirmHandler: @escaping () -> Void,
        cancelTitle: String = AppStrings.Buttons.cancel,
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
    func showDeleteConfirmation(
        on viewController: UIViewController,
        title: String = AppStrings.Alerts.deleteStepTitle,
        message: String = AppStrings.Alerts.deleteStepMessage,
        deleteHandler: @escaping () -> Void,
        cancelHandler: (() -> Void)? = nil
    ) {
        showConfirmation(
            on: viewController,
            title: title,
            message: message,
            confirmTitle: AppStrings.Buttons.delete,
            confirmStyle: .destructive,
            confirmHandler: deleteHandler,
            cancelTitle: AppStrings.Buttons.cancel,
            cancelHandler: cancelHandler
        )
    }

    func showSuccess(
        on viewController: UIViewController,
        title: String = AppStrings.Alerts.successTitle,
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
