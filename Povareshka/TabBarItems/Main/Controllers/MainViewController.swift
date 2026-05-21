//
//  ViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit
import RealmSwift

final class MainViewController: BaseController {
    private lazy var activityIndicator = UIActivityIndicatorView.createIndicator(style: .medium, centerIn: view)
//    private var recipes: Results<RecipeModel>!

    private var recipesSupabase: [RecipeShortInfo] = []
    private var recipesRecently: [RecipeShortInfo] = []
    private var categories: [CategorySupabase] = []
    private var isLoading = false

    lazy var homeScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    let trendingCategoryLabel = UILabel(text: AppStrings.Titles.popular,
                                        font: UIFont.helveticalLight(withSize: 16),
                                        textColor: AppColors.gray600,
                                        numberOfLines: 1)
    

    private lazy var trendingCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(Constants.trendingCellSize,
                                       insets: Constants.insentsRightLeftSides),
            cellConfigs: [CollectionViewCellConfig(cellClass: TrendingNowCollectionViewCell.self,
                                                   identifier: TrendingNowCollectionViewCell.id)],
            delegate: self,
            dataSource: self,
            backgroundColor: AppColors.collectionViewBackground
        )
        collectionView.tag = 0
        return collectionView
    }()
    
    let categoriesLabel = UILabel(text: AppStrings.Titles.categories,
                                  font: UIFont.helveticalLight(withSize: 16),
                                  textColor: AppColors.gray600,
                                  numberOfLines: 1)
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(CGSize(width: 100, height: 100), // Круглые ячейки 80x80
                                       insets: UIEdgeInsets(top: 0, left: Constants.paddingMedium,
                                                           bottom: 0, right: Constants.paddingMedium)),
            cellConfigs: [CollectionViewCellConfig(cellClass: RoundCategoryCell.self,
                                                   identifier: RoundCategoryCell.id)],
            delegate: self,
            dataSource: self,
            backgroundColor: AppColors.collectionViewBackground
        )
        collectionView.tag = 1
        return collectionView
    }()
    
    
    let recentlyCategoryLabel = UILabel(text: AppStrings.Titles.recently,
                                        font: UIFont.helveticalLight(withSize: 16),
                                        textColor: AppColors.gray600,
                                        numberOfLines: 1)

    private lazy var recentlyCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(CGSize(width: 160, height: 220), insets: Constants.insentsRightLeftSides),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: RecipeSearchCell.self, identifier: RecipeSearchCell.id),
            ],
            delegate: self,
            dataSource: self,
            backgroundColor: AppColors.collectionViewBackground,
            minimumInteritemSpacing: 16,
            minimumLineSpacing: 16
        )
        collectionView.tag = 2
        return collectionView
    }()
    
    @objc func plusButtonTapped() {
        let createRecipeViewController = NewRecipeController()
        navigationController?.pushViewController(createRecipeViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        setupNavigationBar()
        loadData()
    }

    private func setupNavigationBar() {
        navigationItem.title = AppStrings.Titles.main
        addNavBarButtons(at: .right, types: [.system(.add)])
    }
    
    @objc override func navBarRightButtonHandler() {
        let createRecipeViewController = NewRecipeController()
        navigationController?.pushViewController(createRecipeViewController, animated: true)
    }
    
    internal override func setupViews() {
        deactivateAllConstraints(for: view)
        view.addSubview(homeScrollView)
        view.addSubview(activityIndicator)
        homeScrollView.addSubview(trendingCategoryLabel)
        homeScrollView.addSubview(trendingCollectionView)
        
        homeScrollView.addSubview(categoriesLabel)
        homeScrollView.addSubview(categoriesCollectionView)
        
        homeScrollView.addSubview(recentlyCategoryLabel)
        homeScrollView.addSubview(recentlyCollectionView)
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            // vertical scroll
            homeScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            homeScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // categories section (теперь первая)
            categoriesLabel.topAnchor.constraint(equalTo: homeScrollView.topAnchor,
                                                 constant: Constants.paddingSmall),
            categoriesLabel.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor,
                                                     constant: Constants.paddingMedium),

            categoriesCollectionView.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor,
                                                          constant: Constants.paddingSmall),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: homeScrollView.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 130),
            
            // trending section (теперь вторая)
            trendingCategoryLabel.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor,
                                                       constant: Constants.paddingMedium),
            trendingCategoryLabel.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor,
                                                           constant: Constants.paddingMedium),
            
            trendingCollectionView.topAnchor.constraint(equalTo: trendingCategoryLabel.bottomAnchor,
                                                        constant: Constants.paddingSmall),
            trendingCollectionView.widthAnchor.constraint(equalTo: homeScrollView.widthAnchor),
            trendingCollectionView.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor),
            trendingCollectionView.trailingAnchor.constraint(equalTo: homeScrollView.trailingAnchor),
            trendingCollectionView.heightAnchor.constraint(equalToConstant: 260),
            
            // recently section (теперь последняя)
            recentlyCategoryLabel.topAnchor.constraint(equalTo: trendingCollectionView.bottomAnchor,
                                                       constant: Constants.paddingMedium),
            recentlyCategoryLabel.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor,
                                                           constant: Constants.paddingMedium),
            recentlyCollectionView.topAnchor.constraint(equalTo: recentlyCategoryLabel.bottomAnchor,
                                                        constant: Constants.paddingSmall),
            recentlyCollectionView.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor),
            recentlyCollectionView.trailingAnchor.constraint(equalTo: homeScrollView.trailingAnchor),
            recentlyCollectionView.heightAnchor.constraint(equalToConstant: 250),
            recentlyCollectionView.bottomAnchor.constraint(equalTo: homeScrollView.bottomAnchor,
                                                           constant: -Constants.paddingMedium)
        ])
    }

    private func loadData() {
        loadRecipes()
        loadCategories()
    }

    private func loadRecipes() {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()
        Task {
            do {
                let response = try await DataService.shared.fetchRecipesShortInfo()
                
                DispatchQueue.main.async {
                    self.recipesSupabase = response
                    self.recipesRecently = response
                    self.trendingCollectionView.reloadData()
                    self.recentlyCollectionView.reloadData()
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.shared.showError(on: self, error: error)
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func loadCategories() {
        Task {
            await DataService.shared.loadCategories()
            categories = DataService.shared.categories
            categoriesCollectionView.reloadData()
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate (Supabase)
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0: // trending
            return recipesSupabase.count
        case 1: // categories
            return categories.count
        case 2: // recent recipes
            return recipesRecently.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0: // trending
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingNowCollectionViewCell.id, for: indexPath) as? TrendingNowCollectionViewCell else {
                return TrendingNowCollectionViewCell()
            }
            cell.configure(with: recipesSupabase[indexPath.row])
            return cell
            
        case 1: // categories
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RoundCategoryCell.id, for: indexPath) as? RoundCategoryCell else {
                return RoundCategoryCell()
            }
            let category = categories[indexPath.row]
            cell.configure(with: category, isSelected: false)
            return cell
            
        case 2: // recent recipes
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeSearchCell.id, for: indexPath) as? RecipeSearchCell else {
                return RecipeSearchCell()
            }
            cell.configure(with: recipesRecently[indexPath.row])
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            switch collectionView.tag {
            case 0: // trending recipes
                let controller = RecipeWatchController()
                controller.recipeSource = .online(recipesSupabase[indexPath.row].id)
                navigationController?.pushViewController(controller, animated: true)
                
            case 1: // categories
                let selectedCategory = categories[indexPath.row]

                // Переход на вкладку SearchViewController
                if let tabBarController = self.tabBarController as? TabBarController {
                    tabBarController.selectedIndex = Tabs.search.rawValue // Переход на вкладку Search
                }

                // Получаем SearchViewController из TabBarController
                if let searchNavController = tabBarController?.viewControllers?[Tabs.search.rawValue] as? UINavigationController,
                   let searchVC = searchNavController.topViewController as? SearchViewController {
                    // Устанавливаем фильтр по категории
                    let filters = RecipeFilters(maxCookingTime: 0, categories: [selectedCategory.title])
                    searchVC.currentFilters = filters
                    // Запускаем поиск
                    searchVC.performSearch(query: "", filters: filters)
                }
                
            case 2: // recent recipes
                let controller = RecipeWatchController()
                controller.recipeSource = .online(recipesSupabase[indexPath.row].id)
                navigationController?.pushViewController(controller, animated: true)
                
            default:
                break
            }
        }
}

// MARK: Constraints
extension MainViewController {
    func deactivateAllConstraints(for view: UIView) {
        view.removeConstraints(view.constraints)
        for subview in view.subviews {
            subview.removeConstraints(subview.constraints)
        }
    }
}
