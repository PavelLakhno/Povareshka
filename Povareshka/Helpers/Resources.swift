//
//  Resources.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

enum Resources {
    enum Colors {
        static let active = UIColor(hexString: "#FF8C2B")
        static let inactive = UIColor(hexString: "#AEAEAE")
        
        static let background = UIColor(hexString: "#F8F9F9")
        static let separator = UIColor(hexString: "#E8ECEF")
//        static let secondary = UIColor(hexString: "#F0F3FF")
//
        static let titleGray = UIColor(hexString: "#333333")
    }
    
    enum Strings {
        enum TabBar {
            static let mainview = "Главная"
            static let favorite = "Избранное"
            static let shop = "Список"
            static let profile = "Профиль"
        }
    }
    
    enum Images {
        enum TabBar {
            static let mainview = UIImage(named: "main_tab")
            static let favorite = UIImage(named: "favorite_tab")
            static let shop = UIImage(named: "shop_tab")
            static let profile = UIImage(named: "profile_tab")
        }
    }
    
    enum Fonts {
        static func helvelticaRegular(with size: CGFloat) -> UIFont {
            UIFont(name: "Helvetica", size: size) ?? UIFont()
        }
    }

}
