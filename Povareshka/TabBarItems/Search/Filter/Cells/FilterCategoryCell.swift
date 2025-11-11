//
//  FilterCategoryCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.03.2025.
//

import UIKit

class FilterCategoryCell: UICollectionViewCell {
    static let id = "FilterCategoryCell"
    
    private let titleLabel = UILabel(text: AppStrings.Buttons.add,
                                     font: .helveticalRegular(withSize: 14),
                                     textColor: .black,
                                     textAlignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = AppColors.gray100
        layer.cornerRadius = Constants.cornerRadiusBig
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        if isSelected {
            backgroundColor = AppColors.primaryOrange.withAlphaComponent(0.2)
            titleLabel.textColor = AppColors.primaryOrange
        } else {
            backgroundColor = AppColors.gray100
            titleLabel.textColor = .black
        }
    }
}
