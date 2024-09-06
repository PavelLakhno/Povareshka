//
//  NewRecipeController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 02.09.2024.
//

import UIKit

class NewRecipeController: BaseController  {
    
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
        let collectionView = UICollectionView(itemWidth: 350, itemHeight: 220, delegate: self, dataSource: self)
        collectionView.register(CustomViewCell.self, forCellWithReuseIdentifier: CustomViewCell.id)
        return collectionView
    }()
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true)
//        let createRecipeViewController = NewRecipeController()
//        createRecipeViewController.modalPresentationStyle = .automatic
//        present(createRecipeViewController, animated: true, completion: nil)
    }
    //------------
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Основное"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Resources.Colors.orange
        navigationItem.rightBarButtonItem?.tintColor = Resources.Colors.inactive
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupAllUI()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension NewRecipeController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomViewCell.id, for: indexPath) as! CustomViewCell
        return cell
    }
}

// MARK: Constraints

extension NewRecipeController {
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
//            trendingCollectionView.heightAnchor.constraint(equalToConstant: 300),
            trendingCollectionView.bottomAnchor.constraint(equalTo: homeScrollView.bottomAnchor)
            
        ])
    }
    
    func deactivateAllConstraints(for view: UIView) {
        view.removeConstraints(view.constraints)
        for subview in view.subviews {
            subview.removeConstraints(subview.constraints)
        }
    }
}
