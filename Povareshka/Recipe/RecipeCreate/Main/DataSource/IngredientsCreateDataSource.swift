//
//  IngredientsCreateDataSource.swift
//  Povareshka
//
//  Created by user on 01.10.2025.
//

import UIKit
// MARK: - Ingredients Data Source
final class IngredientsCreateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var ingredients: [Ingredient] = []
    var onIngredientsChanged: (([Ingredient]) -> Void)?
    var onIngredientDeleted: ((Int) -> Void)?

    // MARK: - Public Methods
    func updateIngredients(_ ingredients: [Ingredient]) {
        self.ingredients = ingredients
    }
    
    func addIngredient(_ ingredient: Ingredient) {
        ingredients.append(ingredient)
        onIngredientsChanged?(ingredients)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MainIngredientsTableViewCell.id,
            for: indexPath
        ) as? MainIngredientsTableViewCell else {
            return UITableViewCell()
        }
        
        let ingredient = ingredients[indexPath.row]
        cell.configure(with: ingredient)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return ingredients.count > 1
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard ingredients.count > 1 else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            self.onIngredientDeleted?(indexPath.row)
            completion(true)
        }
        
        deleteAction.image = AppImages.Icons.trash
        deleteAction.backgroundColor = AppColors.primaryOrange.withAlphaComponent(0.3)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension IngredientsCreateDataSource: @preconcurrency DataSourceConfigurable {
    func configure(with controller: NewRecipeController) {
        onIngredientsChanged = { [weak controller] ingredients in
            controller?.ingredientsTableView.reloadData()
            controller?.ingredientsTableView.dynamicHeightForTableView()
        }

        onIngredientDeleted = { [weak controller] index in
            guard let controller = controller else { return }
            controller.viewModel.ingredientsDataSource.ingredients.remove(at: index)
            controller.ingredientsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            controller.ingredientsTableView.dynamicHeightForTableView()
        }
    }
}
