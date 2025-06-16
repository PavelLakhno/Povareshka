//
//  Resources.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

enum Resources {
    enum Auth {
        static let supabaseUrl = "https://ixedhtnqygtzezlgpgyg.supabase.co"
        static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4ZWRodG5xeWd0emV6bGdwZ3lnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3NDAyNjEsImV4cCI6MjA2MDMxNjI2MX0.SBzYsv_l0zQmLeroGOL38dik8hzjS0K9XK7MA27soVA"
    }
    
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
            static let back = "Назад"
            static let add = "Добавить"
            static let delete = "Удалить"
            static let reg = "Регистрация"
            static let entrance = "Войти"
            static let addIngredient = "Добавить ингредиент"
            static let addStep = "Добавить шаг"
            static let addPhoto = "Выбрать фото"
            static let forgetPassword = "Забыли пароль?"
        }
        
        enum Placeholders {
            static let login = "Логин (email)"
            static let name = "Имя"
            static let email = "Email"
            static let number = "Тел. +7(123)456-78-90"
            static let password = "Введите пароль"
            static let passwordReg = "Пароль (мин. 6 знаков)"
            static let enterTittle = "Введите название"
            static let enterDescription = "Введите описание"
            static let enterCount = "Введите количество"
            static let enterEmail = "Введите email"
        }
        
        enum Tittles {
            static let ingredient = "Ингредиенты"
            static let cookingStages = "Инструкция"
            static let deleteList = "Удаление списка"
            static let newIngredient = "Новый ингредиент"
            static let correctIngredient = "Изменить ингредиент"
            static let timeCooking = "Время приготовления:"
            static let tableSetting = "Сервировка:"
            static let error = "Ошибка"
            static let success = "Успешно"
        }
        
        enum Messages {
            static let delete = "Ваш список будет очищен без возможности восстановления"
            static let shopListEmpty = "Ваш список покупок пуст"
            static let fieldsEmpty = "Заполните все поля корректно"
            static let regError = "Ошибка регистрации"
            static let uploadAvatarError = "Ошибка загрузки аватарки"
            static let letter = "Письмо для сброса пароля отправлено на"
            static let enterEmail = "Пожалуйста, введите email"
            static let failedSaveData = "Не удалось сохранить данные:"
        }
        
        enum Gender {
            static let man = "Муж"
            static let woman = "Жен"
        }
        
        enum Unit: CaseIterable {
            static let gram = "г"
            static let kgram = "кг"
            static let tablespoon = "ст/л"
            static let teaspoon = "ч/л"
            static let count = "шт"
            static let mlitr = "мл"
            static let litr = "л"
            static let cup = "стакан"
            static let tasty = "по вкусу"
            
            static let allValues = [gram, kgram, tablespoon, teaspoon, count, mlitr, litr, cup, tasty]
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
        
        enum Background {
            static let auth = UIImage(named: "Start_View_background")
            static let reg = UIImage(named: "Registration_View_background")
            static let meet = UIImage(named: "Auth_View_background")
        }
        
        enum Icons {
            static let add = UIImage(systemName: "plus.circle")
            static let back = UIImage(systemName: "chevron.left")
            static let addFill = UIImage(systemName: "plus.circle.fill")
            static let okFill = UIImage(systemName: "checkmark.circle.fill")
            static let trash = UIImage(systemName: "trash")
            static let avatar = UIImage(systemName: "person.circle")
            static let cart = UIImage(systemName: "cart")
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
    
    enum Sizes {
        static let cornerRadius = 12.0
        static let paddingWidth = 20.0
        static let paddingHeight = 16.0
        static let textFieldHeight = 44.0
        static let buttonHeight = 44.0
        static let avatar = 100.0
    }
    
    enum AuthError: Error, LocalizedError {
        case invalidCredentials
        case emailNotVerified
        case accountBlocked
        case networkError(URLError)
        case tooManyRequests
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Invalid email or password"
            case .emailNotVerified:
                return "Please verify your email first"
            case .accountBlocked:
                return "Account temporarily blocked"
            case .networkError(let urlError):
                return "Network error: \(urlError.localizedDescription)"
            case .tooManyRequests:
                return "Too many attempts. Try again later"
            case .unknown(let error):
                return "Unknown error: \(error.localizedDescription)"
            }
        }
        
        var userFriendlyMessage: String {
            switch self {
            case .invalidCredentials:
                return "Неверный email или пароль. Проверьте введенные данные."
            case .emailNotVerified:
                return "Пожалуйста, подтвердите ваш email перед входом."
            case .accountBlocked:
                return "Ваш аккаунт временно заблокирован. Попробуйте позже или свяжитесь с поддержкой."
            case .networkError:
                return "Проблемы с интернет-соединением. Проверьте подключение."
            case .tooManyRequests:
                return "Слишком много попыток входа. Попробуйте через 15 минут."
            case .unknown:
                return "Произошла непредвиденная ошибка. Пожалуйста, попробуйте еще раз."
            }
        }
    }

}
