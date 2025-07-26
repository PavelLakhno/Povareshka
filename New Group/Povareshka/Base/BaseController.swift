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

class BaseController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraintViews()
        configureAppearance()
        navigationItem.rightBarButtonItem?.tintColor =  Resources.Colors.orange
        navigationItem.leftBarButtonItem?.tintColor =  Resources.Colors.orange
    }

}

@objc extension BaseController {
    
    func setupViews() {}
    func setupConstraintViews() {}
    func configureAppearance() {
        view.backgroundColor = Resources.Colors.background
    }
    
//    func configure() {
//        view.backgroundColor = Resources.Colors.background
//    }
    
    func navBarLeftButtonHandler() {
        print("NavBar left button tapped")
    }

    func navBarRightButtonHandler() {
        print("NavBar right button tapped")
    }
   
}

extension BaseController {
    func addNavBarButton(at position: NavBarPosition, with title: String) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(Resources.Colors.active, for: .normal)
        button.setTitleColor(Resources.Colors.inactive, for: .disabled)
        button.titleLabel?.font = Resources.Fonts.helvelticaRegular(with: 17)

        switch position {
        case .left:
            button.addTarget(self, action: #selector(navBarLeftButtonHandler), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        case .right:
            button.addTarget(self, action: #selector(navBarRightButtonHandler), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
    }
    
    func setTitleForNavBarButton(_ title: String, at position: NavBarPosition) {
        switch position {
        case .left:
            (navigationItem.leftBarButtonItem?.customView as? UIButton)?.setTitle(title, for: .normal)
        case .right:
            (navigationItem.rightBarButtonItem?.customView as? UIButton)?.setTitle(title, for: .normal)
        }
        
        view.layoutIfNeeded()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(BaseController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
