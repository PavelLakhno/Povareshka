//
//  ShoppingListManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 31.03.2025.
//

import Foundation

final class ShoppingListManager {
    @MainActor static let shared = ShoppingListManager()
    
    private var ingredients: [Ingredient] = []
    
    private init() {}
    
    func addIngredient(_ ingredient: Ingredient) {
        ingredients.append(ingredient)
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func updateIngredient(_ ingredient: Ingredient, at index: Int) {
        ingredients[index] = ingredient
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func clearList() {
        ingredients.removeAll()
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func getIngredients() -> [Ingredient] {
        return ingredients
    }
    
    func contains(ingredient: Ingredient) -> Bool {
        ingredients.contains { $0.name == ingredient.name && $0.amount == ingredient.amount }
    }
}


//final class ShoppingListManager {
//    @MainActor static let shared = ShoppingListManager()
//    
//    private var ingredients: [IngredientSupabase] = []
//    
//    private init() {}
//    
//    func addIngredient(_ ingredient: IngredientSupabase) {
//        ingredients.append(ingredient)
//        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
//    }
//    
//    func removeIngredient(at index: Int) {
//        ingredients.remove(at: index)
//        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
//    }
//    
//    func updateIngredient(_ ingredient: IngredientSupabase, at index: Int) {
//        ingredients[index] = ingredient
//        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
//    }
//    
//    func clearList() {
//        ingredients.removeAll()
//        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
//    }
//    
//    func getIngredients() -> [IngredientSupabase] {
//        return ingredients
//    }
//    
//    func contains(ingredient: IngredientSupabase) -> Bool {
//        ingredients.contains { $0.name == ingredient.name && $0.amount == ingredient.amount }
//    }
//}
