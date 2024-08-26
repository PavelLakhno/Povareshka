//
//  TabBarController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

enum Tabs: Int, CaseIterable {
    case overview
    case session
    case progress
    case settings
}

class TabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func configureAppearance() {
        tabBar.tintColor = Resources.Colors.active
        tabBar.barTintColor = Resources.Colors.inactive
        tabBar.backgroundColor = .white
        tabBar.layer.borderColor = Resources.Colors.separator.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
        
        let overviewController = UIViewController()
        let sessionController = UIViewController()
        let progressController = UIViewController()
        let settingsController = UIViewController()
        
        let overviewNavigation = UINavigationController(rootViewController: overviewController)
        let sessionNavigation = UINavigationController(rootViewController: sessionController)
        let progressNavigation = UINavigationController(rootViewController: progressController)
        let settingsNavigation = UINavigationController(rootViewController: settingsController)
        
        overviewController.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.overview,
            image: Resources.Images.TabBar.overview,
            tag: Tabs.overview.rawValue
        )
        
        sessionController.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.session,
            image: Resources.Images.TabBar.session,
            tag: Tabs.session.rawValue
        )
        
        progressNavigation.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.progress,
            image: Resources.Images.TabBar.progress,
            tag: Tabs.progress.rawValue
        )
        
        settingsNavigation.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.settings,
            image: Resources.Images.TabBar.settings,
            tag: Tabs.settings.rawValue
        )
        
        setViewControllers([
            overviewNavigation,
            sessionNavigation,
            progressNavigation,
            settingsNavigation
        ], animated: false)
    }


}
