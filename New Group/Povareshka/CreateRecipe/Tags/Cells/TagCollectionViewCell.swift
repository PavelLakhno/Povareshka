//
//  TagCollectionViewCell.swift
//  Povareshka
//
//  Created by user on 18.06.2025.
//

import UIKit

// MARK: - TagCollectionViewCell

class TagCollectionViewCell: UICollectionViewCell {
    static let id = "TagCollectionViewCell"
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    var deleteAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .neutral40 // Серый цвет для тегов
        layer.cornerRadius = 15
        clipsToBounds = true
        
        addSubview(tagLabel)
        addSubview(deleteButton)
        
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tagLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            tagLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -4),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 16),
            deleteButton.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    @objc private func deleteTapped() {
        deleteAction?()
    }
    
    func configure(with tag: String, showDelete: Bool = true) {
        tagLabel.text = tag
        deleteButton.isHidden = !showDelete
    }
}

// MARK: - LeftAlignedCollectionViewFlowLayout
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
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



