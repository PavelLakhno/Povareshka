//
//  ViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit
import RealmSwift

final class MainViewController: BaseController {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var recipes: Results<RecipeModel>!
    
    // SB
    private var recipesSupabase: [RecipeShortInfo] = []
    private var isLoading = false

    lazy var homeScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    let trendingCategoryLabel = UILabel(text: "Популярное",
                                        font: UIFont.helveticalLight(withSize: 16),
                                        textColor: Resources.Colors.secondary ,
                                        numberOfLines: 1)
    
    lazy var trendingCollectionView: UICollectionView = {
        let collectionView = UICollectionView(itemWidth: 320, itemHeight: 220, delegate: self, dataSource: self)
        collectionView.register(TrendingNowCollectionViewCell.self, forCellWithReuseIdentifier: TrendingNowCollectionViewCell.identifier)
        return collectionView
    }()
    
    @objc func plusButtonTapped() {
        let createRecipeViewController = NewRecipeController()
        navigationController?.pushViewController(createRecipeViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Основное"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))

//        createTempData()
//        recipes = StorageManager.shared.realm.objects(RecipeModel.self)
        print("Recipes:")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAllUI()
        // SB
        loadRecipes()
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    func createTempData() {
        if !UserDefaults.standard.bool(forKey: "done") {
            DataManager.shared.createTempData { [unowned self] in
                UserDefaults.standard.set(true, forKey: "done")
                print("SUCCESS")
                trendingCollectionView.reloadData()
            }
        }
    }
    
    private func loadRecipes() {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()
        Task {
            do {
                let response: [RecipeShortInfo] = try await SupabaseManager.shared.client
                    .from("recipes")
                //                    .select("id, title, image_path")
                    .select("""
                            id,
                            title,
                            image_path,
                            user_id,
                            profiles!recipes_user_id_fkey(username, avatar_url)
                        """)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.recipesSupabase = response
                    self.trendingCollectionView.reloadData()
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    print("Ошибка загрузки рецептов: \(error)")
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate (Realm)

//extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        recipes.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingNowCollectionViewCell.identifier, for: indexPath) as! TrendingNowCollectionViewCell
//        cell.photoDish.image = UIImage(data: recipes[indexPath.row].image ?? Data())
//        cell.titleDishLabel.text = recipes[indexPath.row].title
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let recipeWatchVC = RecipeWatchController()
//        recipeWatchVC.recipe = recipes[indexPath.row]
//        navigationController?.pushViewController(recipeWatchVC, animated: true)
//    }
//}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate (Supabase)
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recipesSupabase.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrendingNowCollectionViewCell.identifier,
            for: indexPath
        ) as! TrendingNowCollectionViewCell
        
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
    func setupAllUI() {
        deactivateAllConstraints(for: view)
        view.addSubview(homeScrollView)
        homeScrollView.addSubviews(trendingCategoryLabel, trendingCollectionView)
        
        NSLayoutConstraint.activate([
            //vertical scroll
            homeScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            homeScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            //horizontal scroll
            trendingCategoryLabel.topAnchor.constraint(equalTo: homeScrollView.topAnchor, constant: 10),
            trendingCategoryLabel.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor, constant: 15),
            
            trendingCollectionView.topAnchor.constraint(equalTo: homeScrollView.topAnchor, constant: 30),
            trendingCollectionView.leadingAnchor.constraint(equalTo: homeScrollView.leadingAnchor),
            trendingCollectionView.trailingAnchor.constraint(equalTo: homeScrollView.trailingAnchor),
            trendingCollectionView.widthAnchor.constraint(equalTo: homeScrollView.widthAnchor),
            trendingCollectionView.heightAnchor.constraint(equalToConstant: 260),
            
        ])
    }
    
    func deactivateAllConstraints(for view: UIView) {
        view.removeConstraints(view.constraints)
        for subview in view.subviews {
            subview.removeConstraints(subview.constraints)
        }
    }
}
