//
//  ShoppingListManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 31.03.2025.
//

import Foundation

class ShoppingListManager {
    @MainActor static let shared = ShoppingListManager()
    
    private var ingredients: [IngredientData] = []
    
    private init() {}
    
    func addIngredient(_ ingredient: IngredientData) {
        ingredients.append(ingredient)
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func updateIngredient(_ ingredient: IngredientData, at index: Int) {
        ingredients[index] = ingredient
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func clearList() {
        ingredients.removeAll()
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }
    
    func getIngredients() -> [IngredientData] {
        return ingredients
    }
}

extension Notification.Name {
    static let shoppingListDidChange = Notification.Name("shoppingListDidChange")
}
