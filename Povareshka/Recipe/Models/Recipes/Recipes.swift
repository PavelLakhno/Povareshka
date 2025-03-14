//
//  Recipes.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.11.2024.
//

import Foundation

struct Recipes: Codable {
    let recipes: [Recipe]?
}

struct Recipe: Codable {
    let sourceName: String?
    let extendedIngredients: [Ingredient]?
    let id: Int?
    let title: String?
    let readyInMinutes: Int?
    let servings: Int?
    let image: String?
    let summary: String?
    let analyzedInstructions: [Instruction]?
    let veryPopular: Bool?
}

struct Ingredient: Codable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let image: String?
}

struct Instruction: Codable {
    let steps: [Step]
}

struct Step: Codable {
    let number: Int
    let image: String?
    let describe: String?
}
