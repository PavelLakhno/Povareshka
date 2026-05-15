//
//  SavedRecipesController.swift
//  Povareshka
//
//  Created by user on 30.10.2025.
//

import UIKit
import RealmSwift

class SavedRecipesController: BaseController {
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: RecipeListCell.self, identifier: RecipeListCell.id)
            ],
            delegate: self,
            dataSource: self,
            separatorStyle: .singleLine
        )
        return tableView
    }()
    
    private let emptyStateView = EmptyStateView(
        title: "Нет сохраненных рецептов",
        message: "Сохраняйте понравившиеся рецепты, чтобы они были доступны офлайн",
        iconName: "arrow.down.to.line.circle"
    )
    
    // MARK: - Properties
    private let storageManager = StorageManager.shared
    private var savedRecipes: Results<RecipeModel>?
    private var notificationToken: NotificationToken?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        loadSavedRecipes()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    // MARK: - Setup
    internal override func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Сохраненные рецепты"
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.isHidden = true
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Data Loading
    private func loadSavedRecipes() {
        savedRecipes = storageManager.getAllSavedRecipes()
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func setupObservers() {
        notificationToken = savedRecipes?.observe { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.performBatchUpdates({
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                })
                self.updateEmptyState()
            case .error:
                break
            }
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = savedRecipes?.isEmpty ?? true
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - UITableView Delegate & DataSource
extension SavedRecipesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedRecipes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeListCell.id, for: indexPath) as? RecipeListCell,
              let recipe = savedRecipes?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: recipe)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let recipe = savedRecipes?[indexPath.row] else { return }
        openRecipeWatchController(with: recipe)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.deleteRecipe(at: indexPath)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Actions
    private func deleteRecipe(at indexPath: IndexPath) {
        guard let recipe = savedRecipes?[indexPath.row] else { return }
        
        let alert = UIAlertController(
            title: "Удалить рецепт?",
            message: "Рецепт \"\(recipe.title)\" будет удален с устройства",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            let success = self?.storageManager.deleteRecipe(recipe.id) ?? false
            if !success {
                self?.showError(message: "Не удалось удалить рецепт")
            }
        })
        
        present(alert, animated: true)
    }
    
    private func openRecipeWatchController(with recipe: RecipeModel) {
        let controller = RecipeWatchController()
        controller.recipeSource = .offline(recipe)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    private func createRecipeDetailsResponse(from recipe: RecipeModel) -> RecipeDetailsResponse {
        // Конвертируем Realm модель в структуры Supabase для совместимости
        let recipeSupabase = RecipeSupabase(
            id: recipe.id,
            userId: recipe.userId,
            title: recipe.title,
            description: recipe.recipeDescription,
            imagePath: nil, // Для офлайн режима не используем пути
            readyInMinutes: recipe.readyInMinutes,
            servings: recipe.servings,
            difficulty: recipe.difficulty,
            isPublic: recipe.isPublic,
            createdAt: recipe.createdAt,
            updatedAt: recipe.updatedAt
        )
        
        let ingredients = recipe.ingredients.map { ingredient in
            IngredientSupabase(
                id: ingredient.id,
                recipeId: recipe.id,
                name: ingredient.name,
                amount: ingredient.amount,
                measure: ingredient.measure,
                orderIndex: ingredient.orderIndex
            )
        }
        
        let instructions = recipe.instructions.map { instruction in
            InstructionSupabase(
                id: instruction.id,
                recipeId: recipe.id,
                stepNumber: instruction.stepNumber,
                description: instruction.descriptionText,
                imagePath: nil, // Для офлайн режима не используем пути
                orderIndex: instruction.orderIndex
            )
        }
        
        let categories = recipe.categories.map { category in
            CategorySupabase(
                id: category.id,
                title: category.title,
                iconName: category.iconName
            )
        }
        
        let tags = recipe.tags.map { tag in
            RecipeTagSupabase(id: tag.id, recipeId: tag.recipeId, tag: tag.name)
            
        }

        return RecipeDetailsResponse(
            recipe: recipeSupabase,
            ingredients: Array(ingredients),
            instructions: Array(instructions),
            tags: Array(tags),
            categories: Array(categories),
            averageRating: 0, // В офлайн режиме рейтинги не сохраняем
            userRating: nil
        )
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


