//
//  ViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit
import RealmSwift

final class MainViewController: BaseController {
    
    private var recipes: Results<RecipeModel>!

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
        let createRecipeViewController = NewRecipeController()//RecipeAddController()
//        let navVC = UINavigationController(rootViewController: createRecipeViewController)
//        navVC.modalPresentationStyle = .automatic
//        present(navVC, animated: true, completion: nil)
        navigationController?.pushViewController(createRecipeViewController, animated: true)
    }
    //------------
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Основное"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonTapped))
//        navigationItem.rightBarButtonItem?.tintColor = Resources.Colors.orange
        createTempData()
        recipes = StorageManager.shared.realm.objects(RecipeModel.self)
        print("Recipes:")
        print(recipes[0].title)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupAllUI()
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
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingNowCollectionViewCell.identifier, for: indexPath) as! TrendingNowCollectionViewCell
        cell.photoDish.image = UIImage(data: recipes[indexPath.row].image ?? Data())
        cell.titleDishLabel.text = recipes[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recipeWatchVC = RecipeWatchController()
        recipeWatchVC.recipe = recipes[indexPath.row]
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
