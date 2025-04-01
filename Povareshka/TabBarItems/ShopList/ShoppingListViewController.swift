//
//  ShopViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 27.08.2024.
//

import UIKit

class ShoppingListViewController: BaseController {

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ShoppingListCell")
        return table
    }()
    
    private let addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        return button
    }()
    
    private let clearButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
        return button
    }()
    
    private var ingredients: [IngredientData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupNotifications()
        loadIngredients()
        title = "Shopping List"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [addButton, clearButton]
        addButton.target = self
        addButton.action = #selector(addButtonTapped)
        clearButton.target = self
        clearButton.action = #selector(clearButtonTapped)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(shoppingListDidChange),
            name: .shoppingListDidChange,
            object: nil
        )
    }
    
    private func loadIngredients() {
        ingredients = ShoppingListManager.shared.getIngredients()
        tableView.reloadData()
    }
    
    @objc private func shoppingListDidChange() {
        loadIngredients()
    }
    
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "Add Ingredient", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Ingredient name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Quantity"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alert.textFields?[0].text,
                  let quantity = alert.textFields?[1].text,
                  !name.isEmpty else { return }
            
            let ingredient = IngredientData(name: name, amount: quantity)
            ShoppingListManager.shared.addIngredient(ingredient)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func clearButtonTapped() {
        let alert = UIAlertController(
            title: "Clear List",
            message: "Are you sure you want to clear the entire shopping list?",
            preferredStyle: .alert
        )
        
        let clearAction = UIAlertAction(title: "Clear", style: .destructive) { _ in
            ShoppingListManager.shared.clearList()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(clearAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath)
        let ingredient = ingredients[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(ingredient.name) (\(ingredient.amount))"
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ShoppingListManager.shared.removeIngredient(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ingredient = ingredients[indexPath.row]
        let alert = UIAlertController(title: "Edit Ingredient", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = ingredient.name
            textField.placeholder = "Ingredient name"
        }
        
        alert.addTextField { textField in
            textField.text = ingredient.amount
            textField.placeholder = "Quantity"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let name = alert.textFields?[0].text,
                  let quantity = alert.textFields?[1].text,
                  !name.isEmpty else { return }
            
            let updatedIngredient = IngredientData(name: name, amount: quantity)
            ShoppingListManager.shared.updateIngredient(updatedIngredient, at: indexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

}
