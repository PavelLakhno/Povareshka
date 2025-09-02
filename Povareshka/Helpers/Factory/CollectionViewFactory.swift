//
//  CollectionViewFactory.swift
//  Povareshka
//
//  Created by user on 03.08.2025.
//

import UIKit

enum CollectionViewType {
    case horizontalFixedSize(CGSize? = nil, insets: UIEdgeInsets? = nil)
    case verticalFixedSize(CGSize? = nil, insets: UIEdgeInsets? = nil)
    case dynamicSize(useLeftAlignedLayout: Bool, scrollDirection: UICollectionView.ScrollDirection, insets: UIEdgeInsets? = nil)
}

struct CollectionViewCellConfig {
    let cellClass: AnyClass
    let identifier: String
}


@MainActor
func createCollectionView(
    type: CollectionViewType,
    cellConfigs: [CollectionViewCellConfig],
    delegate: UICollectionViewDelegate? = nil,
    dataSource: UICollectionViewDataSource? = nil,
    backgroundColor: UIColor = .clear,
    showsHorizontalScrollIndicator: Bool = false,
    showsVerticalScrollIndicator: Bool = false,
    isScrollEnabled: Bool = true,
    minimumInteritemSpacing: CGFloat = 8,
    minimumLineSpacing: CGFloat = 8
) -> UICollectionView {
    let layout: UICollectionViewFlowLayout
    switch type {
    case .horizontalFixedSize(let size, let insets):
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        if let size = size {
            layout.itemSize = size
        }
        
        if let insets = insets {
            layout.sectionInset = insets
        }
    case .verticalFixedSize(let size, let insets):
        layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        if let size = size {
            layout.itemSize = size
        }
        if let insets = insets {
            layout.sectionInset = insets
        }
    case .dynamicSize(let useLeftAlignedLayout, let scrollDirection, let insets):
        layout = useLeftAlignedLayout ? LeftAlignedCollectionViewFlowLayout() : UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        if let insets = insets {
            layout.sectionInset = insets
        }
    }
    
    layout.minimumInteritemSpacing = minimumInteritemSpacing
    layout.minimumLineSpacing = minimumLineSpacing
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = backgroundColor
    collectionView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
    collectionView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
    collectionView.isScrollEnabled = isScrollEnabled
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.delegate = delegate
    collectionView.dataSource = dataSource
    
    for config in cellConfigs {
        collectionView.register(config.cellClass, forCellWithReuseIdentifier: config.identifier)
    }
    
    return collectionView
}

// MARK: - LeftAlignedCollectionViewFlowLayout
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        for layoutAttribute in attributes {
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}
