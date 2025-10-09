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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
    }
    
    private func configureAppearance() {
        tabBar.tintColor = AppColors.primaryOrange
        tabBar.backgroundColor = .white
        tabBar.layer.borderColor = AppColors.gray100.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.masksToBounds = true
        
        let mainviewController = MainViewController()
        let favoriteController = SearchViewController()
        let shopController = ShoppingListViewController()
        let profileController = ProfileViewController()
        
        let mainviewNavigation =  UINavigationController(rootViewController: mainviewController)
        let favoriteNavigation = UINavigationController(rootViewController: favoriteController)
        let shopNavigation = UINavigationController(rootViewController: shopController)
        let profileNavigation = UINavigationController(rootViewController: profileController)
        
        mainviewNavigation.tabBarItem = UITabBarItem(
            title: AppStrings.TabBar.mainview,
            image: AppImages.TabBar.mainview,
            tag: Tabs.mainview.rawValue
        )
        
        favoriteNavigation.tabBarItem = UITabBarItem(
            title: AppStrings.TabBar.search,
            image: AppImages.TabBar.search,
            tag: Tabs.favorite.rawValue
        )
        
        shopNavigation.tabBarItem = UITabBarItem(
            title: AppStrings.TabBar.shop,
            image: AppImages.TabBar.shop,
            tag: Tabs.shop.rawValue
        )
        
        profileNavigation.tabBarItem = UITabBarItem(
            title: AppStrings.TabBar.profile,
            image: AppImages.TabBar.profile,
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
