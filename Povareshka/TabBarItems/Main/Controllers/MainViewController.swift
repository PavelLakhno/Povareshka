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
    private var isLoading = false

    lazy var homeScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    let trendingCategoryLabel = UILabel(text: Resources.Strings.Titles.popular,
                                        font: UIFont.helveticalLight(withSize: 16),
                                        textColor: Resources.Colors.secondary ,
                                        numberOfLines: 1)
    

    private lazy var trendingCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(Constants.trendingCellSize,
                                       insets: Constants.insentsRightLeftSides),
            cellConfigs: [CollectionViewCellConfig(cellClass: TrendingNowCollectionViewCell.self,
                                                   identifier: TrendingNowCollectionViewCell.id)],
            delegate: self,
            dataSource: self,
            backgroundColor: .white
        )
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
    }

    private func setupNavigationBar() {
        navigationItem.title = Resources.Strings.Titles.main
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
        
        loadRecipes()
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            //vertical scroll
            homeScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            homeScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //horizontal scroll
            trendingCategoryLabel.topAnchor.constraint(equalTo: homeScrollView.topAnchor,
                                                       constant: Constants.paddingSmall),
            trendingCategoryLabel.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor,
                                                           constant: Constants.paddingMedium),
            trendingCollectionView.topAnchor.constraint(equalTo: trendingCategoryLabel.bottomAnchor,
                                                        constant: Constants.paddingSmall),
            trendingCollectionView.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor),
            trendingCollectionView.trailingAnchor.constraint(equalTo: homeScrollView.trailingAnchor),
            trendingCollectionView.widthAnchor.constraint(equalTo: homeScrollView.widthAnchor),
            trendingCollectionView.heightAnchor.constraint(equalToConstant: 260),
            
        ])
    }

    private func loadRecipes() {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()
        Task {
            do {
                let response = try await DataService.shared.loadShortRecipesInfo()
                
                DispatchQueue.main.async {
                    self.recipesSupabase = response
                    self.trendingCollectionView.reloadData()
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.shared.showError(on: self, error: error)
                    print("Ошибка загрузки рецептов: \(error)")
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate (Supabase)
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recipesSupabase.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingNowCollectionViewCell.id, for: indexPath) as? TrendingNowCollectionViewCell else {
            return TrendingNowCollectionViewCell()
        }
        cell.configure(with: recipesSupabase[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeWatchVC = RecipeWatchController()
        recipeWatchVC.recipeId = recipesSupabase[indexPath.row].id
        navigationController?.pushViewController(recipeWatchVC, animated: true)
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
