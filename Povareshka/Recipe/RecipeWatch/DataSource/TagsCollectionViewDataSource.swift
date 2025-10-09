//
//  TagsCollectionViewDataSource.swift
//  Povareshka
//
//  Created by user on 01.10.2025.
//

import UIKit

final class TagsCollectionViewDataSource: NSObject {
    
    // MARK: - Properties
    var tags: [String] = []
    
    // MARK: - Public Methods
    func updateTags(_ tags: [String]) {
        self.tags = tags
    }
}

// MARK: - UICollectionViewDataSource
extension TagsCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TagCollectionViewCell.id,
            for: indexPath
        ) as? TagCollectionViewCell else {
            return TagCollectionViewCell()
        }
        
        cell.configure(with: tags[indexPath.item], showDelete: false)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TagsCollectionViewDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let tag = tags[indexPath.item]
        let font = UIFont.helveticalRegular(withSize: 14)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (tag as NSString).size(withAttributes: attributes)
        return CGSize(width: size.width + 24, height: 30)
    }
}
