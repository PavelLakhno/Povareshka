//
//  CategoriesCreateDataSource.swift
//  Povareshka
//
//  Created by user on 06.10.2025.
//

import UIKit

// MARK: - Categories Data Source
final class CategoriesCreateDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    var selectedCategories: [CategorySupabase] = []
    var onAddCategoryTapped: (() -> Void)?
    
    // MARK: - Public Methods
    func updateSelectedCategories(_ categories: [CategorySupabase]) {
        self.selectedCategories = categories
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedCategories.count + 1 // +1 для кнопки добавления
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddCategoryGridCell.id,
                for: indexPath
            ) as? AddCategoryGridCell else {
                return UICollectionViewCell()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryGridCell.id,
                for: indexPath
            ) as? CategoryGridCell else {
                return UICollectionViewCell()
            }
            
            let category = selectedCategories[indexPath.item - 1]
            cell.configure(with: category.title, iconName: category.iconName, isSelected: true)
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item == 0 else { return }
        onAddCategoryTapped?()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let padding: CGFloat = 16 * 2
        let spacing: CGFloat = 8 * 2
        let availableWidth = collectionView.bounds.width - padding - spacing
        let cellWidth = availableWidth / 3
        return CGSize(width: cellWidth, height: Constants.heightStandart)
    }
}

extension CategoriesCreateDataSource: @preconcurrency DataSourceConfigurable {
    func configure(with controller: NewRecipeController) {
        onAddCategoryTapped = { [weak controller] in
            controller?.addCategoriesTapped()
        }
    }
}
