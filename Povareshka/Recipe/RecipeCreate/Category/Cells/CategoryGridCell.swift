//
//  CategoryGridCell.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//


import UIKit

final class CategoryGridCell: UICollectionViewCell {
    static let id = "CategoryGridCell"
    
    private let iconView = UIImageView(
        size: Constants.iconCellSizeBig,
        contentMode: .scaleAspectFit,
        tintColor: AppColors.primaryOrange,
        backgroundColor: .clear
    )
    
    private let titleLabel = UILabel(
        font: .helveticalRegular(withSize: 12),
        textColor: .black,
        textAlignment: .center,
        numberOfLines: 2
    )
    
    private let stackView = UIStackView(
        axis: .vertical,
        alignment: .center,
        spacing: Constants.spacingSmall
    )
    
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
        iconView.image = nil
        titleLabel.text = nil
    }
    
    private func setupViews() {
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(stackView)
        
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }
    
    func configure(with category: String, iconName: String, isSelected: Bool) {
        titleLabel.text = category
        iconView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        backgroundColor = isSelected ? AppColors.primaryOrange.withAlphaComponent(0.2) : AppColors.gray100
        layer.borderWidth = isSelected ? 1 : 0
        layer.borderColor = isSelected ? AppColors.primaryOrange.cgColor : UIColor.clear.cgColor
    }
}
