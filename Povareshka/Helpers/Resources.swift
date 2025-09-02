//
//  Resources.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

enum Constants {
    static let imageAspectRatio: CGFloat = 1.5
    static let categoryCellSize = CGSize(width: 100, height: 100)
    static let trendingCellSize = CGSize(width: 320, height: 220)
    
    static let insentsRightLeftSides = UIEdgeInsets(top: 0, left: Constants.paddingMedium,
                                              bottom: 0, right: Constants.paddingMedium)
    static let insetsAllSides = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    static let cornerRadiusBig: CGFloat = 20
    static let cornerRadiusMedium: CGFloat = 15
    static let cornerRadiusSmall: CGFloat = 10
    
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingWidth: CGFloat = 20

    static let photosSectionHeight: CGFloat = 140
    static let photoCollectionHeight: CGFloat = 100
    static let heightStandart: CGFloat = 100
    static let buttonHeight: CGFloat = 44
    static let height: CGFloat = 44
    
    static let iconCellSizeBig = CGSize(width: 40, height: 40)
    static let iconCellSizeMedium = CGSize(width: 30, height: 30)
    static let iconCellSizeSmall = CGSize(width: 20, height: 20)
    
    static let photoCellSizeMedium = CGSize(width: 80, height: 80)
    static let photoCellSizeBig = CGSize(width: 100, height: 100)
    
    static let tagSizeButton = CGSize(width: 100, height: 40)

    static let spacingSmall: CGFloat = 4
    static let spacingMedium: CGFloat = 8
    static let spacingBig: CGFloat = 16
}


enum Resources {
    enum Auth {
        static let supabaseUrl = "https://ixedhtnqygtzezlgpgyg.supabase.co"
        static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4ZWRodG5xeWd0emV6bGdwZ3lnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3NDAyNjEsImV4cCI6MjA2MDMxNjI2MX0.SBzYsv_l0zQmLeroGOL38dik8hzjS0K9XK7MA27soVA"
        static let supabaseRedirect = "povareshka-supabase://reset-password"
    }
    
    enum Colors {
        static let active = UIColor(hexString: "#FF8C2B")
        static let inactive = UIColor(hexString: "#AEAEAE")
        static let orange = UIColor(hexString: "#F8A362")
        
        static let background = UIColor(hexString: "#F8F9F9")
        static let backgroundLight = UIColor(hexString: "#F1F1F1")
        static let backgroundMedium = UIColor(hexString: "#D8D8D8")
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
            static let ok = "Ок"
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
            static let addPhoto = "Добавить фото"
            static let changePhoto = "Изменить фото"
            static let addTag = "Добавить тэг"
            static let addCategory = "Добавить категории"
            static let passwordForget = "Забыли пароль?"
            static let passwordReset = "Сбросить пароль"
            
            static let rate = "Оценить"
            static let update = "Изменить"
            
            
            static let watchPhotos = "Просмотреть все"
        }
        
        enum Placeholders {
            static let login = "Логин (email)"
            static let name = "Имя"
            static let email = "Email"
            static let number = "Тел. +7(123)456-78-90"
            static let password = "Введите пароль"
            static let passwordReg = "Пароль (мин. 6 знаков)"
            static let passwordNew = "Новый пароль"
            static let passwordRepeat = "Повторите пароль"
            
            static let enterTitle = "Введите название"
            static let enterDescription = "Введите описание"
            static let enterCount = "Введите количество"
            static let enterEmail = "Введите email"
            
            static let enterIngredientName = "Название"
            static let enterAmount = "Количество"
            static let enterMeasure = "Мера изм."
            
            static let enterTag = "Введите тег"
            static let enterCategory = "Введите категорию"
            static let enterText = "Введите текст"
        }
        
        enum Titles {
            static let ingredient = "Ингредиенты"
            static let cookingStages = "Инструкция"
            static let deleteList = "Удаление списка"
            static let newIngredient = "Новый ингредиент"
            static let correctIngredient = "Изменить ингредиент"
            static let main = "Основное"
            static let popular = "Популярное"
            static let profile = "Профиль"

            static let error = "Ошибка"
            static let success = "Успешно"
            static let categories = "Категории"
            static let tags = "Тэги"
            static let newRecipe = "Новый рецепт"
            static let step = "Шаг"
            
            static let addTags = "Добавить теги"
            static let selectCategories = "Категории"
            static let feedback = "Отзывы и оценки"
            
            static let timeCooking = "Время \nприготовления:"
            static let tableSetting = "Сервировка:"
            static let difficulty = "Сложность"
            
            static let opinionUsers = "Мнение пользователей"
            static let rateRecipe = "Ваша оценка"
            static let rating = "Оценить рецепт"
            static let commentOptional = "Комментарий (необязательно)"
            static let photosOptional = "Фото (необязательно)"
            
            static let anonymous = "Аноним"
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
            static let failedDownload = "Не удалось загрузить данные"
            static let enterFields = "Заполните все поля"
            static let passwordMismatch = "Пароли не совпадают"
            static let passwordSixSigns = "Пароль должен содержать минимум 6 символов"
        }
        
        enum Alerts { 
            static let deleteStepTitle = "Удалить шаг?"
            static let deleteStepMessage = "Вы уверены, что хотите удалить этот шаг?"
            static let errorTitle = "Ошибка"
            static let successTitle = "Успех"
            static let enterDescription = "Введите описание шага"
            static let minimumStepsError = "Должен остаться хотя бы один шаг"

            static let enterIngredientName = "Введите название"
            static let enterValidAmount = "Введите корректное количество"
            static let enterMeasure = "Выберите меру измерения"
            
            static let enterTag = "Введите тег"
            static let tagExists = "Тег уже существует"
            static let tagTooLong = "Тег слишком длинный (максимум 20 символов)"
            static let maxTags = "Количество тегов привышено (максимум 10)"
            
            static let maxCategories = "Выбрано максимальное кол-во"
            static let addCategoryTitle = "Не задано"
            static let enterCategory = "Не задано"

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
        
        enum Category: CaseIterable {
            static let breakfast = "Завтраки"
            static let mainCourses = "Основные блюда"
            static let soups = "Супы"
            static let salads = "Салаты"
            static let appetizers = "Закуски"
            static let desserts = "Десерты"
            static let pastries = "Выпечка"
            static let drinks = "Напитки"
            static let saucesAndMarinades = "Соусы и маринады"
            static let pastaAndPizza = "Паста и пицца"
            static let meatDishes = "Мясные блюда"
            static let fishAndSeafood = "Рыба и морепродукты"
            static let sideDishes = "Гарниры"
            static let quickRecipes = "Быстрые рецепты"
            static let childrenDishes = "Детские блюда"
            static let festiveDishes = "Праздничные блюда"
            
            static let allValues = [breakfast, mainCourses, soups, salads,
                                    appetizers, desserts, pastries, drinks,
                                    saucesAndMarinades, pastaAndPizza,
                                    meatDishes, fishAndSeafood, sideDishes,
                                    quickRecipes, childrenDishes, festiveDishes]

        }
        
    }
    
    enum Images {
        enum TabBar {
            static let mainview = UIImage(systemName: "fork.knife")
            static let shop = UIImage(systemName: "cart.fill")
            static let search = UIImage(systemName: "magnifyingglass")
            static let profile = UIImage(systemName: "person.fill")
        }
        
        enum Background {
            static let auth = UIImage(named: "Start_View_background")
            static let reg = UIImage(named: "Registration_View_background")
            static let meet = UIImage(named: "Auth_View_background")
        }
        
        enum Icons {
            static let add = UIImage(systemName: "plus.circle")
            static let back = UIImage(systemName: "chevron.left")
            static let forward = UIImage(systemName: "chevron.right")
            static let addFill = UIImage(systemName: "plus.circle.fill")
            static let okFill = UIImage(systemName: "checkmark.circle.fill")
            static let trash = UIImage(systemName: "trash")
            static let avatar = UIImage(systemName: "person.circle")
            static let cart = UIImage(systemName: "cart")
            static let cameraMain = UIImage(systemName: "camera")
            static let edit = UIImage(systemName: "pencil")
            static let profile = UIImage(systemName: "person.circle.fill")
            static let cancel = UIImage(systemName: "multiply.circle.fill")
            static let deleteX = UIImage(systemName: "xmark")
            static let deleteFill = UIImage(systemName: "xmark.circle.fill")

            
            static let testMealImage = UIImage(named: "mealImage")
            static let testAuthorIcon = UIImage(named: "Martha Stewart")
            
            static let level = UIImage(systemName: "cellularbars")
            static let clockFill = UIImage(systemName: "clock.fill")
            static let clockEmpty = UIImage(systemName: "clock")
            static let persons = UIImage(systemName: "person.2.fill")
            
            static let starEmpty = UIImage(systemName: "star")
            static let starFilled = UIImage(systemName: "star.fill")
            
            static let table = UIImage(systemName: "list.bullet")
            static let collection = UIImage(systemName: "square.grid.2x2")
            
            static let fork = UIImage(systemName: "fork.knife")
            static let heart = UIImage(systemName: "heart.fill")
            
        }
    }
   
    enum Arrays {
        static func createServesArray() -> [String] {
            return Array(1...20).map { "\($0)" }
        }

        static func createCookTimeArray() -> [String] {
            return (Array(1..<20) + stride(from: 20, through: 180, by: 5)).map { "\($0)" }
        }
        
        static func createDifficultyArray() -> [String] {
            return Array(1...5).map { "\($0)" }
        }
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
    
    enum SupabaseError: Error {
        case invalidURL
        case networkError(Error)
        case storageError(String)
        case databaseError(String)

        var localizedDescription: String {
            switch self {
            case .invalidURL: return "Неверный URL сервера"
            case .networkError(let error): return "Ошибка сети: \(error.localizedDescription)"
            case .storageError(let desc): return "Ошибка хранилища: \(desc)"
            case .databaseError(let desc): return "Ошибка базы данных: \(desc)"
            }
        }
    }
    
    enum Settings {
        enum SettingType: Int, CaseIterable {
            case servings = 0
            case cookTime = 1
            case difficulty = 2
            
            var title: String {
                switch self {
                case .servings: return Strings.Titles.tableSetting
                case .cookTime: return Strings.Titles.timeCooking
                case .difficulty: return Strings.Titles.difficulty
                }
            }
            
            var iconName: UIImage? {
                switch self {
                case .servings: return Images.Icons.persons
                case .cookTime: return Images.Icons.clockFill
                case .difficulty: return Images.Icons.level
                }
            }
            
            var data: [String] {
                switch self {
                case .servings: return Arrays.createServesArray()
                case .cookTime: return Arrays.createCookTimeArray()
                case .difficulty: return Arrays.createDifficultyArray()
                }
            }
            
            func formatValue(_ value: String, maxDifficulty: Int) -> String {
                switch self {
                case .servings: return "\(value) чел"
                case .cookTime: return "\(value) мин"
                case .difficulty: return "\(value) / \(maxDifficulty)"
                }
            }
        }
    }
}
