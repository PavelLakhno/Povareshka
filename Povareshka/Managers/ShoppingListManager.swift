//
//  ShoppingListManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 31.03.2025.
//

import Foundation

final class ShoppingListManager {
    @MainActor static let shared = ShoppingListManager()

    private let storageKey = "shopping_list_ingredients"
    private var ingredients: [Ingredient] = []

    private init() {
        load()
    }

    // MARK: - Public Interface

    func addIngredient(_ ingredient: Ingredient) {
        guard !contains(ingredient: ingredient) else { return }
        ingredients.append(ingredient)
        save()
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }

    func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
        save()
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }

    func updateIngredient(_ ingredient: Ingredient, at index: Int) {
        ingredients[index] = ingredient
        save()
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }

    func clearList() {
        ingredients.removeAll()
        save()
        NotificationCenter.default.post(name: .shoppingListDidChange, object: nil)
    }

    func getIngredients() -> [Ingredient] {
        return ingredients
    }

    func contains(ingredient: Ingredient) -> Bool {
        ingredients.contains { $0.name == ingredient.name && $0.amount == ingredient.amount }
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(ingredients) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([Ingredient].self, from: data) else { return }
        ingredients = saved
    }
}
