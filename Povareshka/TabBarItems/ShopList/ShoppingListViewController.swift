//
//  ShopViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 27.08.2024.
//

import UIKit

class ShoppingListViewController: BaseController {
        private let emptyStateView: UIView = {
            let view = UIView()
            view.isHidden = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
    
        private let emptyStateImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = AppImages.Icons.cart
            imageView.tintColor = .gray.withAlphaComponent(0.6)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
    
        private let emptyStateLabel: UILabel = {
            let label = UILabel()
            label.text = AppStrings.Messages.shopListEmpty
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "ShoppingListCell")
        return table
    }()
    
    private var ingredients: [IngredientData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupNotifications()
        loadIngredients()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(emptyStateView)

        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200),

            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 100),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.title = AppStrings.TabBar.shop
        addNavBarButtons(
            at: .right,
            types: [.system(.add), .system(.trash)],
            actions: [#selector(addButtonTapped), #selector(clearButtonTapped)]
        )
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
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !ingredients.isEmpty
        tableView.isHidden = ingredients.isEmpty
    }
    
    @objc private func shoppingListDidChange() {
        loadIngredients()
    }
    
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: AppStrings.Buttons.add, message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = AppStrings.Placeholders.enterTitle
        }
        
        alert.addTextField { textField in
            textField.placeholder = AppStrings.Placeholders.enterCount
        }
        
        let addAction = UIAlertAction(title: AppStrings.Buttons.done, style: .default) { _ in
            guard let name = alert.textFields?[0].text,
                  let quantity = alert.textFields?[1].text,
                  !name.isEmpty else { return }
            
            let ingredient = IngredientData(name: name, amount: quantity)
            ShoppingListManager.shared.addIngredient(ingredient)
        }
        
        let cancelAction = UIAlertAction(title: AppStrings.Buttons.cancel, style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func clearButtonTapped() {
        let alert = UIAlertController(
            title: AppStrings.Titles.deleteList,
            message: AppStrings.Messages.delete,
            preferredStyle: .alert
        )
        
        let clearAction = UIAlertAction(title: AppStrings.Buttons.delete, style: .destructive) { _ in
            ShoppingListManager.shared.clearList()
        }
        
        let cancelAction = UIAlertAction(title: AppStrings.Buttons.cancel, style: .cancel)
        
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
        let alert = UIAlertController(title: AppStrings.Titles.correctIngredient, message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = ingredient.name
            textField.placeholder = AppStrings.Placeholders.enterTitle
        }
        
        alert.addTextField { textField in
            textField.text = ingredient.amount
            textField.placeholder = AppStrings.Placeholders.enterCount
        }
        
        let saveAction = UIAlertAction(title: AppStrings.Buttons.save, style: .default) { _ in
            guard let name = alert.textFields?[0].text,
                  let quantity = alert.textFields?[1].text,
                  !name.isEmpty else { return }
            
            let updatedIngredient = IngredientData(name: name, amount: quantity)
            ShoppingListManager.shared.updateIngredient(updatedIngredient, at: indexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: AppStrings.Buttons.cancel, style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

}
