//
//  UIModel.swift
//  Povareshka
//
//  Created by user on 10.11.2025.
//

import Foundation

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

struct RecipeMetaData {
    let readyInMinutes: Int?
    let servings: Int?
    let difficulty: Int?
    
    init(readyInMinutes: Int? = nil, servings: Int? = nil, difficulty: Int? = nil) {
        self.readyInMinutes = readyInMinutes
        self.servings = servings
        self.difficulty = difficulty
    }
}
