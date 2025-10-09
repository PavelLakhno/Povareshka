//
//  MainIngredientsTVCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import UIKit

final class MainIngredientsTableViewCell: UITableViewCell {
    static let id = "MainIngredientsTableViewCell"
    
    private let contentStackView = UIStackView(
        axis: .horizontal,
        alignment: .center,
        spacing: 12
    )
    
    private let ingredientName = UILabel(font: .helveticalRegular(withSize: 16),
                                         backgroundColor: .white,
                                         textColor: .black,
                                         textAlignment: .center,
                                         layer: true)
    private let weightName = UILabel(font: .helveticalRegular(withSize: 16),
                                     backgroundColor: .white,
                                     textColor: .black,
                                     textAlignment: .center,
                                     layer: true)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.ingredientName.text = ""
        self.weightName.text = ""
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = AppColors.gray100
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(ingredientName)
        contentStackView.addArrangedSubview(weightName)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingSmall),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingSmall),

            ingredientName.heightAnchor.constraint(equalToConstant:  Constants.height),
            weightName.heightAnchor.constraint(equalToConstant:  Constants.height),
            weightName.widthAnchor.constraint(equalToConstant:  Constants.heightStandart)
        ])
    }
    
    func configure(with ingredient: Ingredient) {
        ingredientName.text = ingredient.name
        ingredientName.addLeftPadding(20)
        weightName.text = "\(ingredient.amount) \(ingredient.measure)"
    }

}
