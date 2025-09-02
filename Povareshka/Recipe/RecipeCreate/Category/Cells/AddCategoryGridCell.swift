//
//  AddCategoryGridCell.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

final class AddCategoryGridCell: UICollectionViewCell {
    static let id = "AddCategoryGridCell"
    
    private let iconView = UIImageView(
        image: Resources.Images.Icons.addFill,
        size: Constants.iconCellSizeBig,
        contentMode: .scaleAspectFit,
        tintColor: .systemGray2,
        backgroundColor: .clear
    )
    
    private let titleLabel = UILabel(
        text: Resources.Strings.Buttons.add,
        font: .helveticalRegular(withSize: 12),
        textColor: .black,
        textAlignment: .center
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
   
    private func setupViews() {
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(stackView)
        
        backgroundColor = Resources.Colors.backgroundMedium
        
        // Настройка скругления углов
        layer.cornerRadius = Constants.cornerRadiusMedium
        contentView.layer.cornerRadius = Constants.cornerRadiusMedium
        contentView.layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }
}
