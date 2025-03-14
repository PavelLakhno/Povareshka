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
        static let orange = UIColor(hexString: "#F8A362")
        
        static let background = UIColor(hexString: "#F8F9F9")
        static let separator = UIColor(hexString: "#E8ECEF")
        static let secondary = UIColor(hexString: "#8A8A8A")
//
        static let titleGray = UIColor(hexString: "#333333")
        static let titleBackground = UIColor(hexString: "#000000", alpha: 0.4)
        static let titleBackgroundRes = UIColor(hexString: "#AEAEAE")
    }
    
    enum Strings {
        enum TabBar {
            static let mainview = "Главная"
            static let favorite = "Избранное"
            static let shop = "Список"
            static let profile = "Профиль"
            static let search = "Поиск"
        }
    }
    
    enum Images {
        enum TabBar {
            static let mainview = UIImage(named: "main_tab")
            static let favorite = UIImage(named: "favorite_tab")
            static let shop = UIImage(named: "shop_tab")
            static let profile = UIImage(named: "profile_tab")
            static let search = UIImage(named: "search_tab")
        }
        
        enum Icons {
            
            static let arrowLeft = UIImage(named: "Icons/Arrow-Left")
            static let arrowRight = UIImage(named: "Icons/Arrow-Right")
            static let bookmark = UIImage(named: "Icons/Bookmark")
            static let clock = UIImage(named: "Icons/Clock")
            static let edit = UIImage(named: "Icons/Edit")
            static let location = UIImage(named: "Icons/Location")
            static let minusBorder = UIImage(named: "Icons/Minus-Border")
            static let moreVertical = UIImage(named: "Icons/More-1")
            static let moreHorizontal = UIImage(named: "Icons/More")
            static let play = UIImage(named: "Icons/Play")
            static let plusBorder = UIImage(named: "Icons/Plus-Border")
            static let plus = UIImage(named: "Icons/Plus")
            static let profile = UIImage(named: "Icons/Profile")
            static let recipe = UIImage(named: "Icons/Recipe")
            static let search = UIImage(named: "Icons/Search")
            static let star = UIImage(named: "Icons/Star")
            static let tickCircle = UIImage(named: "Icons/tick-circle")
            
        }
    }
    
    enum Fonts {
        static func helvelticaRegular(with size: CGFloat) -> UIFont {
            UIFont(name: "Helvetica", size: size) ?? UIFont()
        }
    }

}
