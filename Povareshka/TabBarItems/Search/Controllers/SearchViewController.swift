//
//  SearchViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 27.08.2024.
//

import UIKit

final class SearchViewController: BaseController {

    // MARK: - UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск рецептов"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var filterButton = UIButton(
        image: AppImages.Icons.slider,
        tintColor: AppColors.primaryOrange,
        size: Constants.viewSize50,
        target: self,
        action: #selector(filterButtonTapped)
    )

    private lazy var collectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .verticalFixedSize(Constants.viewSize100),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: RecipeSearchCell.self, identifier: RecipeSearchCell.id),
            ],
            delegate: self,
            dataSource: self,
            showsVerticalScrollIndicator: false,
            isScrollEnabled: true,
            minimumInteritemSpacing: 16,
            minimumLineSpacing: 16
        )
        return collectionView
    }()
    
    private let emptyStateView = UIView(size: Constants.viewSize200,
                                        backgroundColor: AppColors.gray100)
    
    private let emptyStateImageView = UIImageView(
        image: AppImages.TabBar.search,
        size: Constants.viewSize50,
        tintColor: AppColors.gray600,
        backgroundColor: AppColors.gray100
    )
    
    private let emptyStateLabel = UILabel(text: AppStrings.Messages.enterText,
                                          font: .helveticalRegular(withSize: 16),
                                          textColor: .gray,
                                          textAlignment: .center)
    

    // MARK: - Properties
    private var allRecipes: [RecipeShortInfo] = []
    private var filteredRecipes: [RecipeShortInfo] = []
    private var isSearching: Bool = false
    private var currentSearchTask: Task<Void, Never>?
    var currentFilters: RecipeFilters?
    private var searchTimer: Timer?
    private let searchDelay: TimeInterval = 0.5
    
    private lazy var searchActivityIndicator = UIActivityIndicatorView.createIndicator(
        style: .medium,
        centerIn: view
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        loadAllRecipes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let filters = currentFilters, (!filters.categories.isEmpty || filters.maxCookingTime > 0), filteredRecipes.isEmpty {
            performSearch(query: searchBar.text ?? "", filters: filters)
        }
    }
    // MARK: - Setup
    
    override func setupViews() {
        title = AppStrings.TabBar.search
        
        view.addSubview(searchBar)
        view.addSubview(filterButton)
        view.addSubview(collectionView)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.rightView = searchActivityIndicator
            textField.rightViewMode = .unlessEditing
        }
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingSmall),
            searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -Constants.paddingSmall),
            
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Constants.paddingSmall),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: Constants.paddingMedium),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    // MARK: - Data Loading
    private func loadAllRecipes() {
        Task {
            do {
                let recipes = try await DataService.shared.fetchRecipesShortInfo()

                DispatchQueue.main.async {
                    self.allRecipes = recipes
                    self.collectionView.reloadData()
                    self.updateEmptyState()

                    if let filters = self.currentFilters, (!filters.categories.isEmpty || filters.maxCookingTime > 0) {
                        self.performSearch(query: self.searchBar.text ?? "", filters: filters)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.shared.show(on: self,
                                             title: AppStrings.Alerts.errorTitle,
                                             message: "Ошибка загрузки рецептов")
                    self.updateEmptyState()
                }
            }
        }
    }

    func performSearch(query: String, filters: RecipeFilters? = nil) {
        showLoading()
        
        // Отменяем предыдущий поиск
        currentSearchTask?.cancel()
        
        isSearching = !query.isEmpty || (filters != nil && (!filters!.categories.isEmpty || filters!.maxCookingTime > 0))
        
        currentSearchTask = Task {
            // Добавляем небольшую проверку на случай быстрой отмены
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 секунды
            guard !Task.isCancelled else { return }
            
            do {
                let recipes: [RecipeShortInfo]
                
                //
                recipes = try await DataService.shared.searchRecipes(
                    query: query.isEmpty ? nil : query,
                    categoryTitles: filters?.categories ?? [],
                    maxCookingTime: filters?.maxCookingTime
                )
                
                if !Task.isCancelled {
                    DispatchQueue.main.async {
                        self.filteredRecipes = recipes
                        self.collectionView.reloadData()
                        self.hideLoading()
                        self.updateEmptyState()
                    }
                }
            } catch {
                if !Task.isCancelled {
                    DispatchQueue.main.async {
                        self.filteredRecipes = []
                        self.collectionView.reloadData()
                        self.hideLoading()
                        self.updateEmptyState()
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateEmptyState() {
        let recipesToShow = isSearching ? filteredRecipes : allRecipes
        let shouldShowEmptyState = recipesToShow.isEmpty
        
        emptyStateView.isHidden = !shouldShowEmptyState
        collectionView.isHidden = shouldShowEmptyState
        
        if shouldShowEmptyState {
            emptyStateImageView.image = isSearching ? AppImages.TabBar.search : AppImages.Icons.book
            emptyStateLabel.text = isSearching ? AppStrings.Messages.notFoundRecipe : AppStrings.Messages.notCreateRecipe
        }
    }
    
    // MARK: - Actions
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.selectedCategories = Set(currentFilters?.categories ?? [])
        filterVC.selectedTime = Float(currentFilters?.maxCookingTime ?? 60)
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredRecipes.count : allRecipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeSearchCell.id, for: indexPath) as? RecipeSearchCell else {
            return RecipeSearchCell()
        }
        let recipe = isSearching ? filteredRecipes[indexPath.item] : allRecipes[indexPath.item]
        cell.configure(with: recipe)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipe = isSearching ? filteredRecipes[indexPath.item] : allRecipes[indexPath.item]
        
        let controller = RecipeWatchController()
        controller.recipeSource = .online(recipe.id)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: width * 1.3)
    }
}

// MARK: - UISearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Отменяем предыдущий таймер
        searchTimer?.invalidate()
        
        if searchText.isEmpty {
            // Если текст очищен - сразу сбрасываем поиск
            isSearching = false
            filteredRecipes = []
            currentSearchTask?.cancel()
            updateEmptyState()
            collectionView.reloadData()
        } else {
            searchTimer = Timer.scheduledTimer(withTimeInterval: searchDelay, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.performSearch(query: searchText, filters: self.currentFilters)
                }
            }
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTimer?.invalidate()
        if let searchText = searchBar.text, !searchText.isEmpty {
            performSearch(query: searchText, filters: currentFilters)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // При отмене поиска
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchTimer?.invalidate()
        currentSearchTask?.cancel()
        isSearching = false
        filteredRecipes = []
        updateEmptyState()
        collectionView.reloadData()
    }
}

// MARK: - FilterViewControllerDelegate
extension SearchViewController: @preconcurrency FilterViewControllerDelegate {
    func filterViewController(_ viewController: FilterViewController, didApplyFilters filters: RecipeFilters) {
        currentFilters = filters
        let query = searchBar.text ?? ""
        performSearch(query: query, filters: filters)
    }
}

// В BaseController или прямо в SearchViewController
extension SearchViewController {
    private func showLoading() {
        // Реализация показа индикатора загрузки
        collectionView.isHidden = true
        emptyStateView.isHidden = true
        searchActivityIndicator.startAnimating()
        // Показать activity indicator
    }
    
    private func hideLoading() {
        // Скрыть индикатор загрузки
        searchActivityIndicator.stopAnimating()
        collectionView.isHidden = false
        updateEmptyState()
    }
}
