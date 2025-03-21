//
//  TrendingNowCollectionViewCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 28.08.2024.
//

import UIKit
import Kingfisher

class TrendingNowCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let identifier = "TrendingNowCell"
    
    private var photoDish = UIImageView(image: Resources.Images.Icons.testMealImage, cornerRadius: 16)

    private var ratingContainerView = UIView(withBackgroundColor: Resources.Colors.titleBackground, cornerRadius: 8)
    private var ratingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private var ratingLabel = UILabel(text: "4,5",
                                      font: .helveticalBold(withSize: 14),
                                      textColor: .white,
                                      numberOfLines: 1)
    
    
    
    private var titleDishLabel = UILabel(text: "Яичница с тостами",
                                         font: .helveticalBold(withSize: 16),
                                         textColor: .white,
                                         numberOfLines: 0)
    
    private var creatorStackView = UIStackView(axis: .horizontal, aligment: .center, spacing: 8)
    private var creatorImageView = UIImageView(image: Resources.Images.Icons.testAuthorIcon, cornerRadius: 16)
    private var creatorLabel = UILabel(text: "Ольга Митрофановна",
                                       font: .helveticalRegular(withSize: 12),
                                       textColor: Resources.Colors.secondary,
                                       numberOfLines: 1)
    
    
    
    
    func configureCell(with recipe: String) {
        titleDishLabel.text = recipe
    }
    
    let gradientLayer = CAGradientLayer()
    
    private func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.4, 0.9]

        photoDish.layer.addSublayer(gradientLayer)
    }

    private func setupUI() {
        addSubviews(photoDish, creatorStackView)
        setupGradientLayer()
        photoDish.addSubviews(ratingContainerView, titleDishLabel)
        
        ratingContainerView.addSubviews(ratingImageView, ratingLabel)
        creatorStackView.addArrangedSubview(creatorImageView)
        creatorStackView.addArrangedSubview(creatorLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoDish.topAnchor.constraint(equalTo: topAnchor),
            photoDish.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoDish.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoDish.heightAnchor.constraint(equalToConstant: 180),
            
            ratingContainerView.topAnchor.constraint(equalTo: photoDish.topAnchor, constant: 8),
            ratingContainerView.leadingAnchor.constraint(equalTo: photoDish.leadingAnchor, constant: 8),
            
            
            ratingImageView.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: 8),
            ratingImageView.topAnchor.constraint(equalTo: ratingContainerView.topAnchor, constant: 6),
            ratingImageView.bottomAnchor.constraint(equalTo: ratingContainerView.bottomAnchor, constant: -6),

            ratingLabel.leadingAnchor.constraint(equalTo: ratingImageView.trailingAnchor, constant: 8),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingImageView.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingContainerView.trailingAnchor, constant: -8),

            titleDishLabel.bottomAnchor.constraint(equalTo: photoDish.bottomAnchor, constant: -6),
            titleDishLabel.leadingAnchor.constraint(equalTo: photoDish.leadingAnchor, constant: 8),

            creatorStackView.topAnchor.constraint(equalTo: photoDish.bottomAnchor, constant: 8),
            creatorStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            
            creatorImageView.heightAnchor.constraint(equalToConstant: 32),
            creatorImageView.widthAnchor.constraint(equalTo: creatorImageView.heightAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }

}
