//
//  ViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

final class MainViewController: BaseController {

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Основное"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupAllUI()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingNowCollectionViewCell.identifier, for: indexPath) as! TrendingNowCollectionViewCell
        return cell
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
