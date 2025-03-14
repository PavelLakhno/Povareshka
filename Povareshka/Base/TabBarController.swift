//
//  TabBarController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

enum Tabs: Int, CaseIterable {
    case mainview
    case favorite
    case shop
    case profile
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
        
        let mainviewController = MainViewController()
        let favoriteController = SearchViewController()
        let shopController = ShopViewController()
        let profileController = ProfileViewController()
        
        let mainviewNavigation = NavBarController(rootViewController: mainviewController)
        let favoriteNavigation = NavBarController(rootViewController: favoriteController)
        let shopNavigation = NavBarController(rootViewController: shopController)
        let profileNavigation = NavBarController(rootViewController: profileController)
        
        mainviewNavigation.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.mainview,
            image: Resources.Images.TabBar.mainview,
            tag: Tabs.mainview.rawValue
        )
        
        favoriteNavigation.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.search,
            image: Resources.Images.TabBar.search,
            tag: Tabs.favorite.rawValue
        )
        
        shopNavigation.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.shop,
            image: Resources.Images.TabBar.shop,
            tag: Tabs.shop.rawValue
        )
        
        profileNavigation.tabBarItem = UITabBarItem(
            title: Resources.Strings.TabBar.profile,
            image: Resources.Images.TabBar.profile,
            tag: Tabs.profile.rawValue
        )
        
        setViewControllers([
            mainviewNavigation,
            favoriteNavigation,
            shopNavigation,
            profileNavigation
        ], animated: false)
    }


}
