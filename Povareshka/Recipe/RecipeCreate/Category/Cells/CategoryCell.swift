//
//  CategoryCell.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let id = "CategoryCell"

    private let titleLabel = UILabel(
        font: .helveticalRegular(withSize: 17),
        textColor: .black
    )
    
    private let iconView = UIImageView(
        size: Constants.iconCellSizeMedium,
        contentMode: .scaleAspectFit,
        tintColor: AppColors.primaryOrange
    )
 
    private let checkmarkView = UIImageView(
        image: AppImages.Icons.okFill,
        size: Constants.iconCellSizeMedium,
        contentMode: .scaleAspectFit,
        tintColor: AppColors.primaryOrange
    )
    
    private let stackView = UIStackView(
        axis: .horizontal,
        alignment: .center,
        spacing: Constants.spacingBig
    )
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(checkmarkView)
        contentView.addSubview(stackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingMedium),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingMedium)
        ])
    }
    
    func configure(with category: CategorySupabase, isSelected: Bool) {
        iconView.image = UIImage(named: category.iconName)?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = category.title
        checkmarkView.isHidden = !isSelected
    }
}
