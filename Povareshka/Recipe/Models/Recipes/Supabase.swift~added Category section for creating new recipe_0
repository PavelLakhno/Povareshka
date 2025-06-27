//
//  Supabase.swift
//  Povareshka
//
//  Created by user on 25.06.2025.
//

import Foundation

struct ProfileSB: Codable, Identifiable {
    let id: UUID
    let username: String?
    let email: String?
    let website: String?
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case website
        case avatar = "avatar_url"
    }
}

struct RecipeSB: Codable, Identifiable {
    let id: UUID
    let creatorId: UUID
    let title: String
    let description: String?
    let imagePath: String?
    let readyInMinutes: Int?
    let servings: Int?
    let isPublic: Bool
    let difficulty: String?    // easy/medium/hard
    let categories: [String?]     // breakfast/lunch/dinner
    let rating: Double?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId = "user_id"
        case title
        case description
        case imagePath = "image_path"
        case readyInMinutes = "ready_in_minutes"
        case servings
        case isPublic = "is_public"
        case difficulty
        case categories
        case rating
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct RecipeIngredientSB: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let name: String
    let amount: String
    let orderIndex: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case amount
        case orderIndex = "order_index"
    }
}

struct RecipeInstructionSB: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let stepNumber: Int
    let description: String?
    let imagePath: String?
    let orderIndex: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case stepNumber = "step_number"
        case description
        case imagePath = "image_path"
        case orderIndex = "order_index"
    }
}

struct RecipeTagSB: Codable {
    let id: UUID
    let recipeId: UUID
    let tag: String
}

struct RecipeShortInfoSB: Decodable {
    let id: UUID
    let title: String
    let imagePath: String?
    let userId: UUID
    let profile: ProfileShort
    
    struct ProfileShort: Decodable {
        let username: String
        let avatarUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case avatarUrl = "avatar_url"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case imagePath = "image_path"
        case userId = "user_id"
        case profile = "profiles"
    }
    
    // Вычисляемые свойства для удобства
    var authorId: UUID { userId }
    var authorName: String { profile.username }
    var authorAvatarPath: String? { profile.avatarUrl }
}

struct RecipeFeedbackSB: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let userId: UUID
    var rating: Int?          // 1-5
    var comment: String?
    var photos: [String]?    // Пути к фото
    var isFavorite: Bool     // Вынести в отдельную модель!
    let createdAt: Date
    let updatedAt: Date      // Добавить для отслеживания изменений
}

struct RecipeFavoriteSB: Codable {
    let id: UUID
    let userId: UUID
    let recipeId: UUID
    let createdAt: Date
}

struct ReviewPhotoSB: Codable, Identifiable {
    let id: UUID
    let reviewId: UUID      // Ссылка на RecipeInteraction.id
    let path: String
    let createdAt: Date
}
