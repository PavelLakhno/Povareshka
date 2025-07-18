//
//  CategorySelectionController.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

final class CategoriesSelectionController: UITableViewController {
    
    var categories: [RecipeCategory] = RecipeCategory.allCategories()
    var selectedCategories: [String] = []
    var completion: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigation()
    }
    
    private func setupTableView() {
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.id)
        tableView.rowHeight = 56
        tableView.separatorStyle = .none
    }
    
    private func setupNavigation() {
        title = "Выберите категории"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.id, for: indexPath) as! CategoryCell
        cell.configure(with: categories[indexPath.row])
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categories[indexPath.row].isSelected.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Actions
    
    @objc private func doneTapped() {
        selectedCategories = categories.filter { $0.isSelected }.map { $0.title }
        completion?(selectedCategories)
        navigationController?.popViewController(animated: true)
    }
}
