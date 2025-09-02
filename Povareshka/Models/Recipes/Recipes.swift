//
//  Recipes.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.11.2024.
//

import Foundation

struct User {
    let uid: UUID
    let name: String
    let email: String
    let phone: String
    let gender: String
    let avatarURL: String
    let createdAt: Date
    let likeRecipes: [Recipe]
    let myRecipes: [Recipe]
}

struct Recipes: Codable {
    let recipes: [Recipe]?
}

struct Recipe: Codable {
    let userID: String
    let category: [String]
    let tags: [String]
    let title: String?
    let readyInMinutes: Int?
    let servings: Int?
    let image: Data?
    let ingredients: [Ingredient]?
    let instructions: [Instruction]?
    let createdAt: Date
}

struct Ingredient: Codable {
    var name: String
    var amount: String
    var measure: String
}

struct Instruction: Codable {
    var number: Int
    var image: Data?
    var describe: String
}

struct IngredientData: Codable {
    let id: UUID
    var name: String
    var amount: String
    var isChecked: Bool
    
    init(id: UUID = UUID(), name: String, amount: String = "", isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.amount = amount
        self.isChecked = isChecked
    }
}

// Вернуться обязательно!

// Структура для ответа RPC
struct RecipeDetailsResponse: Codable {
    let recipe: RecipeSupabase
    let ingredients: [IngredientSupabase]
    let instructions: [InstructionSupabase]
    let tags: [String]
    let categories: [CategorySupabase]
    let averageRating: Double
    let userRating: Rating?
    
    enum CodingKeys: String, CodingKey {
        case recipe, ingredients, instructions, tags, categories
        case averageRating = "average_rating"
        case userRating = "user_rating"
    }
}
