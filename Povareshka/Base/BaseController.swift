//
//  BaseController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 27.08.2024.
//

import UIKit

enum NavBarPosition {
    case left
    case right
}

enum NavBarButtonType {
    case title(String)
    case image(UIImage?)
    case system(UIBarButtonItem.SystemItem)
}

class BaseController: UIViewController {
    // MARK: - ScrollableController
    var scrollView: UIScrollView? { nil } 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureAppearance()
        configureNavigationBar()
    }
    
    // MARK: - Navigation Bar Configuration
    func configureNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.tintColor = AppColors.primaryOrange
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.helveticalRegular(withSize: 16)
        ]
        
        navigationBar?.standardAppearance = appearance
        navigationBar?.scrollEdgeAppearance = appearance
        
        navigationBar?.addBottomBorder(
            with: AppColors.gray100,
            height: 1
        )
    }
    
    deinit {
        KeyboardManager.removeKeyboardNotifications(observer: self)
    }
    
    // MARK: check leaks
//    deinit {
//        let className = String(describing: type(of: self))
//        Task { @MainActor in
//            UIViewController.deinitCounter += 1
//            print("🔴 DEINIT: \(className) - Total: \(UIViewController.deinitCounter)")
//        }
//        NotificationCenter.default.removeObserver(self)
//    }
}

// MARK: - Base Methods
@objc extension BaseController {
    func setupViews() {
        hideKeyboardWhenTappedAround()
        registerKeyboardNotifications()
    }
    func setupConstraints() {}
    func configureAppearance() {
        view.backgroundColor = AppColors.gray100
    }
}

// MARK: - Cofig Bar Buttons
extension BaseController {
    func addNavBarButtons(at position: NavBarPosition,
                         types: [NavBarButtonType],
                         actions: [Selector?] = []) {
        
        var barButtonItems: [UIBarButtonItem] = []
        
        for (index, type) in types.enumerated() {
            let action = actions.indices.contains(index) ? actions[index] : nil
            let barButtonItem = createBarButtonItem(type: type, position: position, action: action)
            barButtonItems.append(barButtonItem)
        }
        
        switch position {
        case .left:
            navigationItem.leftBarButtonItems = barButtonItems
        case .right:
            navigationItem.rightBarButtonItems = barButtonItems
        }
    }
    
    
    private func createBarButtonItem(type: NavBarButtonType,
                                   position: NavBarPosition,
                                   action: Selector?) -> UIBarButtonItem {
        
        switch type {
        case .title(let title):
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(AppColors.primaryOrange, for: .normal)
            button.setTitleColor(AppColors.gray400, for: .disabled)
            button.titleLabel?.font = .helveticalRegular(withSize: 16)
            
            if let action = action {
                button.addTarget(self, action: action, for: .touchUpInside)
            } else {
                let defaultAction = position == .left ?
                    #selector(navBarLeftButtonHandler) :
                    #selector(navBarRightButtonHandler)
                button.addTarget(self, action: defaultAction, for: .touchUpInside)
            }
            
            return UIBarButtonItem(customView: button)
            
        case .image(let image):
            let button = UIButton(type: .system)
            button.setImage(image, for: .normal)
            button.tintColor = AppColors.primaryOrange
            
            if let action = action {
                button.addTarget(self, action: action, for: .touchUpInside)
            } else {
                let defaultAction = position == .left ?
                    #selector(navBarLeftButtonHandler) :
                    #selector(navBarRightButtonHandler)
                button.addTarget(self, action: defaultAction, for: .touchUpInside)
            }
            
            return UIBarButtonItem(customView: button)
            
        case .system(let systemItem):
            return UIBarButtonItem(
                barButtonSystemItem: systemItem,
                target: self,
                action: action ?? (position == .left ?
                    #selector(navBarLeftButtonHandler) :
                    #selector(navBarRightButtonHandler))
            )
        }
    }
    
    @objc func navBarLeftButtonHandler() {
        print("NavBar left button tapped")
    }
    
    @objc func navBarRightButtonHandler() {
        print("NavBar right button tapped")
    }
}

// MARK: - Utility Methods
extension BaseController {
    func adjustForKeyboard(_ keyboardHeight: CGFloat) {
        scrollView?.contentInset.bottom = keyboardHeight
        scrollView?.verticalScrollIndicatorInsets.bottom = keyboardHeight
        
        // Автопрокрутка к активному полю
        if let activeField = view.findFirstResponder() {
            let activeFieldFrame = activeField.convert(activeField.bounds, to: scrollView)
            let visibleFrameHeight = (scrollView?.frame.height ?? 0) - keyboardHeight
            let offsetY = max(0, activeFieldFrame.maxY - visibleFrameHeight + 50)
            scrollView?.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        }
    }
    
    func resetKeyboardAdjustment() {
        scrollView?.contentInset.bottom = 0
        scrollView?.verticalScrollIndicatorInsets.bottom = 0
    }
    
    private func registerKeyboardNotifications() {
        KeyboardManager.registerForKeyboardNotifications(
            observer: self,
            showSelector: #selector(keyboardWillShow(_:)),
            hideSelector: #selector(keyboardWillHide)
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        adjustForKeyboard(keyboardFrame.height)
    }
    
    @objc private func keyboardWillHide() {
        resetKeyboardAdjustment()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

