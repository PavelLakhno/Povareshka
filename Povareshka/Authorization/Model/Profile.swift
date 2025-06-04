//
//  Profile.swift
//  Povareshka
//
//  Created by user on 01.06.2025.
//

import Foundation

// MARK: - Модель для обновления профиля
//struct Profile: Codable {
//    let id: UUID
//    let username: String?
//    let fullName: String?
//    let website: String?
//    let avatarURL: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case username
//        case fullName = "full_name"
//        case website
//        case avatarURL = "avatar_url"
//    }
//}

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String?
    let fullName: String?
    let website: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case website
        case avatarURL = "avatar_url"
    }
}

struct RecipeSupabase: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String?
    let imagePath: String?
    let readyInMinutes: Int?
    let servings: Int?
    let isPublic: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case imagePath = "image_path"
        case readyInMinutes = "ready_in_minutes"
        case servings
        case isPublic = "is_public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct IngredientSupabase: Codable, Identifiable {
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

struct InstructionSupabase: Codable, Identifiable {
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
