//
//  AppStrings.swift
//  Povareshka
//
//  Created by user on 24.09.2025.
//

import Foundation

enum AppStrings {
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
        static let emptyData = "Отсутствуют данные"
        static let mainPhoto = "Нет основного фото"
        static let mainTitle = "Нет названия"
        static let mainDescription = "Нет описания"
        static let emptyCategory = "Не добавлено ни одной категории"
        static let emptyIngredient = "Не добавлено ни одного ингридиента"
        static let emptyStep = "Нет инструкций"
        
        
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
