//
//  RatingHeaderView.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

final class RatingHeaderView: UIView {
    private let ratingLabel = UILabel(font: .helveticalBold(withSize: 30),
                                      textColor: .black,
                                      textAlignment: .left)
    private let titleLabel = UILabel(text: Resources.Strings.Titles.opinionUsers,
                                     font: .helveticalRegular(withSize: 14),
                                     textColor: .secondaryLabel,
                                     textAlignment: .left, numberOfLines: 1)
    private let starsView = UIStackView(axis: .horizontal,
                                        alignment: .leading,
                                        spacing: Constants.spacingSmall)
    private let verticalStack = UIStackView(axis: .vertical,
                                            alignment: .leading,
                                            spacing: Constants.spacingSmall)
    private let mainStack = UIStackView(axis: .horizontal,
                                        alignment: .leading,
                                        spacing: Constants.spacingMedium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    func configure(rating: Double) {
        ratingLabel.text = String(format: "%.1f", rating)
        
        starsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for i in 1...5 {
            let star = UIImageView(
                image: i <= Int(rating) ? Resources.Images.Icons.starFilled : Resources.Images.Icons.starEmpty,
                size: Constants.iconCellSizeSmall,
                contentMode: .scaleAspectFit,
                tintColor: Resources.Colors.orange
            )
            starsView.addArrangedSubview(star)
        }
    }
    
    private func setupView() {
        verticalStack.addArrangedSubview(starsView)
        verticalStack.addArrangedSubview(titleLabel)
        
        mainStack.addArrangedSubview(ratingLabel)
        mainStack.addArrangedSubview(verticalStack)
        
        addSubview(mainStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: Constants.paddingMedium),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.paddingMedium),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.paddingMedium),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.paddingMedium)
        ])
    }
}

