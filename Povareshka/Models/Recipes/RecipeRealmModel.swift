//
//  RecipeModel.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import Foundation
import RealmSwift

// Основная модель рецепта для Realm
class RecipeModel: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title: String
    @Persisted var recipeDescription: String?
    @Persisted var imageData: Data?
    @Persisted var readyInMinutes: Int?
    @Persisted var servings: Int?
    @Persisted var difficulty: Int?
    @Persisted var isPublic: Bool
    @Persisted var createdAt: Date
    @Persisted var updatedAt: Date
    @Persisted var userId: UUID
    
    // Связи
    @Persisted var ingredients: List<IngredientModel>
    @Persisted var instructions: List<InstructionModel>
    @Persisted var tags: List<TagRealm>
    @Persisted var categories: List<CategoryRealm>
    
    convenience init(from response: RecipeDetailsResponse, imageData: Data?) {
        self.init()
        self.id = response.recipe.id
        self.title = response.recipe.title
        self.recipeDescription = response.recipe.description
        self.imageData = imageData
        self.readyInMinutes = response.recipe.readyInMinutes
        self.servings = response.recipe.servings
        self.difficulty = response.recipe.difficulty
        self.isPublic = response.recipe.isPublic
        self.createdAt = response.recipe.createdAt
        self.updatedAt = response.recipe.updatedAt
        self.userId = response.recipe.userId
        
        // Конвертируем ингредиенты
        response.ingredients.forEach { ingredient in
            self.ingredients.append(IngredientModel(from: ingredient))
        }
        
        // Конвертируем инструкции
        response.instructions.forEach { instruction in
            self.instructions.append(InstructionModel(from: instruction))
        }
        
        // Добавляем теги
        response.tags.forEach { tag in
            self.tags.append(TagRealm(from: tag))
        }
        
        // Конвертируем категории
        response.categories.forEach { category in
            self.categories.append(CategoryRealm(from: category))
        }

    }
    
    var tagStrings: [String] {
        return tags.map { $0.name }
    }

}

class IngredientModel: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var amount: String
    @Persisted var measure: String
    @Persisted var orderIndex: Int
    
    convenience init(from ingredient: IngredientSupabase) {
        self.init()
        self.id = ingredient.id
        self.name = ingredient.name
        self.amount = ingredient.amount
        self.measure = ingredient.measure
        self.orderIndex = ingredient.orderIndex
    }
}

class InstructionModel: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var stepNumber: Int
    @Persisted var descriptionText: String
    @Persisted var imageData: Data?
    @Persisted var orderIndex: Int
    
    convenience init(from instruction: InstructionSupabase) {
        self.init()
        self.id = instruction.id
        self.stepNumber = instruction.stepNumber
        self.descriptionText = instruction.description ?? ""
        self.orderIndex = instruction.orderIndex ?? 0
        // Note: imageData нужно будет загрузить отдельно
    }
}

class CategoryRealm: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title: String
    @Persisted var iconName: String
    
    convenience init(from category: CategorySupabase) {
        self.init()
        self.id = category.id
        self.title = category.title
        self.iconName = category.iconName
    }
}

class TagRealm: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var recipeId: UUID
    @Persisted var name: String
    
    convenience init(from tag: RecipeTagSupabase) {
        self.init()
        self.id = tag.id
        self.recipeId = tag.recipeId
        self.name = tag.tag
    }
}
