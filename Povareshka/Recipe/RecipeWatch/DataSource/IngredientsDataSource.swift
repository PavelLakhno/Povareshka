//
//  IngredientsDataSource.swift
//  Povareshka
//
//  Created by user on 01.10.2025.
//

import UIKit

final class IngredientsDataSource: NSObject {
    
    // MARK: - Properties
    var ingredients: [IngredientSupabase] = []
    var onAddIngredient: ((Ingredient) -> Void)?
//    var onAddIngredient: ((IngredientSupabase) -> Void)?
    
    // MARK: - Public Methods
    func updateIngredients(_ ingredients: [IngredientSupabase]) {
        self.ingredients = ingredients
    }

}

// MARK: - UITableViewDataSource
extension IngredientsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientCell.id, for: indexPath) as? IngredientCell else {
            return IngredientCell()
        }
        
        let ingredient = ingredients[indexPath.row]

        let newIngredient = Ingredient(name: ingredient.name, amount: ingredient.amount, measure: ingredient.measure)
        let isAdded = ShoppingListManager.shared.contains(ingredient: newIngredient)
        
        cell.configure(with: newIngredient, isAdded: isAdded)
        cell.addActionHandler = { [weak self] ingredient in
            self?.onAddIngredient?(newIngredient)
        }
        
        DispatchQueue.main.async {
            tableView.dynamicHeightForTableView()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension IngredientsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
