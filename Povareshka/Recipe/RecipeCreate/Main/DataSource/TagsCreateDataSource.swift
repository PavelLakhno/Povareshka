//
//  TagsCreateDataSource.swift
//  Povareshka
//
//  Created by user on 06.10.2025.
//

import UIKit

// MARK: - Tags Data Source для создания рецепта
final class TagsCreateDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    private let tagsManager: TagsManager
    var onAddTagTapped: (() -> Void)?
    
    // MARK: - Init
    init(tagsManager: TagsManager) {
        self.tagsManager = tagsManager
        super.init()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsManager.tags.count + 1 // +1 для кнопки добавления
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // Ячейка "Добавить тег"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTagCell", for: indexPath)
            
            // Очищаем предыдущие вьюшки (на всякий случай)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            let label = UILabel()
            label.text = AppStrings.Buttons.addTag
            label.textColor = .white
            label.font = .systemFont(ofSize: 14)
            
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
            
            cell.backgroundColor = AppColors.primaryOrange
            cell.layer.cornerRadius = Constants.cornerRadiusMedium
            cell.clipsToBounds = true
            
            return cell
        } else {
            // Ячейка тега
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TagCollectionViewCell.id,
                for: indexPath
            ) as? TagCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let tag = tagsManager.tags[indexPath.item - 1]
            cell.configure(with: tag)
            cell.deleteAction = { [weak self] in
                self?.tagsManager.removeTag(at: indexPath.item - 1)
            }
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item == 0 else { return }
        onAddTagTapped?()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: 120, height: 30)
        } else {
            let tag = tagsManager.tags[indexPath.item - 1]
            let font = UIFont.systemFont(ofSize: 14)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (tag as NSString).size(withAttributes: attributes)
            return CGSize(width: size.width + 48, height: 30)
        }
    }
}

extension TagsCreateDataSource: @preconcurrency DataSourceConfigurable {
    func configure(with controller: NewRecipeController) {
        onAddTagTapped = { [weak controller] in
            controller?.addTagTapped()
        }
    }
}
