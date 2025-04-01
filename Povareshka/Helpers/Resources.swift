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
        
        enum Buttons {
            static let done = "Готово"
            static let save = "Сохранить"
            static let cancel = "Отменить"
            static let addIngredient = "Добавить ингредиент"
            static let addStep = "Добавить шаг"
        }
        
        enum Placeholders {
            static let enterTittle = "Введите название"
            static let enterDescription = "Введите описание"
            static let cancel = "Отменить"
            static let addIngredient = "Добавить ингредиент"
            static let addStep = "Добавить шаг"
        }
        
        enum Tittles {
            static let ingredient = "Ингредиенты"
            static let cookingStages = "Этапы приготовления"
         }
        
        enum Unit: CaseIterable {
            static let gram = "г"
            static let kgram = "кг"
            static let tablespoon = "ст/л"
            static let teaspoon = "ч/л"
            static let count = "шт"
            static let litr = "л"
            static let cup = "стакан"
            static let tasty = "по вкусу"
            
            static let allValues = [gram, kgram, tablespoon, teaspoon, count, litr, cup, tasty]
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
            static let add = UIImage(systemName: "plus.circle")
            static let trash = UIImage(systemName: "trash")
            static let arrowLeft = UIImage(named: "Icons/Arrow-Left")
            static let arrowRight = UIImage(named: "Icons/Arrow-Right")
            static let bookmark = UIImage(named: "Icons/Bookmark")
            static let cameraMain = UIImage(named: "camera_main")
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
            
            static let testMealImage = UIImage(named: "mealImage")
            static let testAuthorIcon = UIImage(named: "Martha Stewart")
            
        }
    }
    
    enum Fonts {
        static func helvelticaRegular(with size: CGFloat) -> UIFont {
            UIFont(name: "Helvetica", size: size) ?? UIFont()
        }
    }
    
    enum Arrayes {
        static func createServesArray() -> [String] {
            return Array(1...20).map { "\($0)" }
        }

        static func createCookTimeArray() -> [String] {
            return (Array(1..<20) + stride(from: 20, through: 180, by: 5)).map { "\($0)" }
        }
    }

}
