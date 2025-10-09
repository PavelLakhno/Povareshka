//
//  AppError.swift
//  Povareshka
//
//  Created by user on 24.09.2025.
//

import Foundation

protocol AppError: Error {
    var userFriendlyMessage: String { get }
}

// MARK: - Authentication Errors
enum AuthError: AppError {
    case invalidCredentials
    case notAuthenticated
    case emailNotVerified
    case accountBlocked
    case tooManyRequests
    
    var userFriendlyMessage: String {
        switch self {
        case .invalidCredentials:
            return "Неверный email или пароль"
        case .notAuthenticated:
            return "Для выполнения действия требуется авторизация"
        case .emailNotVerified:
            return "Подтвердите ваш email перед входом"
        case .accountBlocked:
            return "Аккаунт заблокирован"
        case .tooManyRequests:
            return "Слишком много попыток. Попробуйте позже"
        }
    }
}

// MARK: - Data Layer Errors
enum DataError: AppError {
    case networkUnavailable
    case operationFailed(description: String)
    case notFound
    case invalidData
    
    var userFriendlyMessage: String {
        switch self {
        case .networkUnavailable:
            return "Отсутствует интернет-соединение"
        case .operationFailed(let description):
            return "Ошибка: \(description)"
        case .notFound:
            return "Данные не найдены"
        case .invalidData:
            return "Некорректные данные"
        }
    }
}

// MARK: - Image Errors
enum ImageError: AppError {
    case operationCancelled
    case invalidImageData
    case uploadFailed
    
    var userFriendlyMessage: String {
        switch self {
        case .operationCancelled:
            return "Операция прервана"
        case .invalidImageData:
            return "Некорректный формат изображения"
        case .uploadFailed:
            return "Не удалось загрузить изображение"
        }
    }
}

// MARK: - Recipe Domain Errors
enum RecipeError: AppError {
    case saveFailed
    case validationFailed(message: String)
    case alreadyInFavorites
    case notInFavorites
    case recipeNotFound
    
    var userFriendlyMessage: String {
        switch self {
        case .saveFailed:
            return "Не удалось сохранить рецепт"
        case .validationFailed(let message):
            return message
        case .alreadyInFavorites:
            return "Рецепт уже в избранном"
        case .notInFavorites:
            return "Рецепт не в избранном"
        case .recipeNotFound:
            return "Рецепт не найден"
        }
    }
}

// MARK: - Review Errors
enum ReviewError: AppError {
    case submissionFailed
    case invalidRating
    case alreadyReviewed
    
    var userFriendlyMessage: String {
        switch self {
        case .submissionFailed:
            return "Не удалось отправить отзыв"
        case .invalidRating:
            return "Некорректная оценка"
        case .alreadyReviewed:
            return "Вы уже оставляли отзыв"
        }
    }
}
