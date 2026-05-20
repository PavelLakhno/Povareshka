//
//  FavoritesController.swift
//  Povareshka
//

import UIKit

enum RecipeListSource {
    case favorites
    case myRecipes

    var navigationTitle: String {
        switch self {
        case .favorites: return "Избранное"
        case .myRecipes: return "Мои рецепты"
        }
    }

    var emptyTitle: String {
        switch self {
        case .favorites: return "Нет избранных рецептов"
        case .myRecipes: return "Нет созданных рецептов"
        }
    }

    var emptyMessage: String {
        switch self {
        case .favorites: return "Добавляйте понравившиеся рецепты в избранное, нажимая на сердечко"
        case .myRecipes: return "Создайте свой первый рецепт и он появится здесь"
        }
    }

    var emptyIcon: UIImage? {
        switch self {
        case .favorites: return AppImages.Icons.heartOutline
        case .myRecipes: return AppImages.Icons.book
        }
    }
}

final class RecipeListController: BaseController {

    private let source: RecipeListSource

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: RecipeListCell.self, identifier: RecipeListCell.id)
            ],
            delegate: self,
            dataSource: self,
            separatorStyle: .singleLine,
        )
        return tableView
    }()

    private lazy var emptyStateView = EmptyStateView(
        title: source.emptyTitle,
        message: source.emptyMessage,
        icon: source.emptyIcon
    )

    private let loadingIndicator = UIActivityIndicatorView.createIndicator(style: .medium)
    private let refreshControl = UIRefreshControl()

    // MARK: - Properties
    private let dataService = DataService.shared
    private var recipes: [RecipeShortInfo] = []

    // MARK: - Init
    init(source: RecipeListSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        loadRecipes()
    }

    // MARK: - Setup
    internal override func setupViews() {
        view.backgroundColor = .systemBackground
        title = source.navigationTitle

        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)

        emptyStateView.isHidden = true
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshRecipes), for: .valueChanged)
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
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Data
    private func loadRecipes() {
        loadingIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = true

        Task {
            do {
                recipes = try await fetchRecipes()
                tableView.reloadData()
                updateEmptyState()
            } catch {
                emptyStateView.isHidden = false
                tableView.isHidden = true
            }
            loadingIndicator.stopAnimating()
        }
    }

    @objc private func refreshRecipes() {
        Task {
            do {
                recipes = try await fetchRecipes()
                tableView.reloadData()
                updateEmptyState()
            } catch {}
            refreshControl.endRefreshing()
        }
    }

    private func fetchRecipes() async throws -> [RecipeShortInfo] {
        switch source {
        case .favorites: return try await dataService.fetchFavoriteRecipes()
        case .myRecipes: return try await dataService.fetchMyRecipes()
        }
    }

    private func updateEmptyState() {
        let isEmpty = recipes.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

// MARK: - UITableView Delegate & DataSource
extension RecipeListController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: RecipeListCell.id,
            for: indexPath
        ) as? RecipeListCell else { return UITableViewCell() }
        cell.configure(with: recipes[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = RecipeWatchController()
        controller.recipeSource = .online(recipes[indexPath.row].id)
        navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard source == .favorites else { return nil }

        let removeAction = UIContextualAction(style: .destructive, title: AppStrings.Buttons.remove) { [weak self] _, _, completion in
            self?.removeFromFavorites(at: indexPath)
            completion(true)
        }
        removeAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [removeAction])
    }

    private func removeFromFavorites(at indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]
        Task {
            do {
                _ = try await dataService.toggleFavorite(recipeId: recipe.id, isCurrentlyFavorite: true)
                recipes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                if recipes.isEmpty { updateEmptyState() }
            } catch {
                AlertManager.shared.show(
                    on: self,
                    title: AppStrings.Alerts.errorTitle,
                    message: AppStrings.Messages.couldNotRemoveFromFavorites
                )
            }
        }
    }
}
