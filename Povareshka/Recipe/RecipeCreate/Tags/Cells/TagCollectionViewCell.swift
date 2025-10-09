//
//  TagCollectionViewCell.swift
//  Povareshka
//
//  Created by user on 18.06.2025.
//

import UIKit

final class TagCollectionViewCell: UICollectionViewCell {
    static let id = "TagCollectionViewCell"
    
    private let tagLabel = UILabel(
        font: .helveticalRegular(withSize: 16),
        textColor: .white,
        textAlignment: .center,
        numberOfLines: 1
    )
    
    private lazy var deleteButton = UIButton(
        image: AppImages.Icons.deleteX,
        size: Constants.iconCellSizeSmall,
        target: self, action: #selector(deleteTapped)
    )
    var deleteAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagLabel.text = nil
    }
    
    private func setupViews() {
        backgroundColor = AppColors.gray600
        layer.cornerRadius = Constants.cornerRadiusMedium
        layer.masksToBounds = true
        
        contentView.addSubview(tagLabel)
        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            tagLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tagLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -Constants.paddingSmall),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingSmall),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    @objc private func deleteTapped() {
        deleteAction?()
    }
    
    func configure(with tag: String, showDelete: Bool = true) {
        tagLabel.text = tag
        deleteButton.isHidden = !showDelete
    }
}



