//
//  RoundCategoryCell.swift
//  Povareshka
//
//  Created by user on 24.10.2025.
//

import UIKit

final class RoundCategoryCell: UICollectionViewCell {
    static let id = "RoundCategoryCell"
    
    private let iconView = UIImageView(
        size: Constants.viewSize40,
        contentMode: .scaleAspectFit,
        tintColor: AppColors.primaryOrange,
        backgroundColor: .clear
    )
    
    private let titleLabel = UILabel(
        font: .helveticalRegular(withSize: 12),
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Делаем ячейку круглой
        layer.cornerRadius = frame.size.width / 2
        layer.masksToBounds = true
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
        
        backgroundColor = AppColors.gray100
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }
    
    func configure(with category: CategorySupabase, isSelected: Bool) {
        titleLabel.text = category.title
        iconView.image = UIImage(named: category.iconName)?.withRenderingMode(.alwaysTemplate)
        backgroundColor = isSelected ? AppColors.primaryOrange.withAlphaComponent(0.2) : AppColors.gray100
        layer.borderWidth = isSelected ? 1 : 0
        layer.borderColor = isSelected ? AppColors.primaryOrange.cgColor : UIColor.clear.cgColor
    }
}
