//
//  RatingView.swift
//  Povareshka
//
//  Created by user on 22.07.2025.
//

import UIKit

final class RatingView: UIView {
    private var stars: [UIButton] = []
    private let stackView = UIStackView(axis: .horizontal,
                                        alignment: .center,
                                        distribution: .fillEqually,
                                        spacing: Constants.spacingMedium)
    
    var didSelectRating: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        for i in 1...5 {
            let button = UIButton()
            button.tag = i
            button.tintColor = AppColors.primaryOrange
            button.setImage(AppImages.Icons.starEmpty, for: .normal)
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            stars.append(button)
            stackView.addArrangedSubview(button)
        }
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with rating: Int) {
        for (index, star) in stars.enumerated() {
            let image = index < rating ?
            AppImages.Icons.starFilled :
            AppImages.Icons.starEmpty
            star.setImage(image, for: .normal)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        configure(with: rating)
        didSelectRating?(rating)
    }
}

