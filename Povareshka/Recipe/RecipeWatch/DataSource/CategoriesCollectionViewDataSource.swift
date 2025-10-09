//
//  CategoriesCollectionViewDataSource.swift
//  Povareshka
//
//  Created by user on 01.10.2025.
//

import UIKit

final class CategoriesCollectionViewDataSource: NSObject {
    
    // MARK: - Properties
    var categories: [CategorySupabase] = []
    
    // MARK: - Public Methods
    func updateCategories(_ categories: [CategorySupabase]) {
        self.categories = categories
    }
}

// MARK: - UICollectionViewDataSource
extension CategoriesCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryGridCell.id,
            for: indexPath
        ) as? CategoryGridCell else {
            return CategoryGridCell()
        }
        
        let category = categories[indexPath.item]
        cell.configure(with: category.title, iconName: category.iconName, isSelected: false)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CategoriesCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return Constants.categoryCellSize
    }
}
