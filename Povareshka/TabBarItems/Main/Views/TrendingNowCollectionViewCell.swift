//
//  TrendingNowCollectionViewCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 28.08.2024.
//

import UIKit
//import Kingfisher

final class TrendingNowCollectionViewCell: UICollectionViewCell {
    static let id = "TrendingNowCell"
     
    private var mainImageTask: Task<Void, Never>?
    private var avatarImageTask: Task<Void, Never>?
    private let dataService = DataService.shared
    
    private lazy var activityIndicator = UIActivityIndicatorView.createIndicator(style: .medium, centerIn: self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var photoDish = UIImageView(
        cornerRadius: Constants.cornerRadiusMedium,
        contentMode: .scaleToFill
    )

    private var ratingContainerView = UIView(
        backgroundColor: Resources.Colors.titleBackground,
        cornerRadius: Constants.cornerRadiusSmall
    )
    
    private var ratingImageView = UIImageView(
        image: Resources.Images.Icons.starFilled?.withTintColor(.systemYellow,
                                                                renderingMode: .alwaysOriginal)
    )
    
    private var ratingLabel = UILabel(
        font: .helveticalBold(withSize: 14),
        textColor: .white,
        textAlignment: .center,
        numberOfLines: 1
    )
    
    private lazy var titleDishLabel = UILabel(
        font: .helveticalBold(withSize: 16),
        textColor: .white,
        numberOfLines: 0
    )
    
    private var creatorStackView = UIStackView(
        axis: .horizontal,
        alignment: .center,
        spacing: Constants.cornerRadiusSmall
    )
    
    private var creatorImageView = UIImageView(cornerRadius: Constants.cornerRadiusMedium)
    
    private var creatorLabel = UILabel(
        font: .helveticalRegular(withSize: 12),
        textColor: Resources.Colors.secondary,
        numberOfLines: 1
    )

    //SB (optimizated)
    func configure(with recipe: RecipeShortInfo) {
        titleDishLabel.text = recipe.title
        creatorLabel.text = recipe.authorName
        
        loadMainImage(path: recipe.imagePath)
        loadAuthorAvatar(path: recipe.authorAvatarPath)
        Task {
            do {
                let averageRating = try await dataService.fetchAverageRating(recipeId: recipe.id)
                ratingLabel.text = "\(averageRating)"
            } catch {
                print("error")
            }
        }
    }
    
    private func loadMainImage(path: String?) {
        guard let path = path else { return }
        
        // Проверяем кэш
        if let cachedImage = ImageCache.shared.image(for: path) {
            photoDish.image = cachedImage
            return
        }
        mainImageTask?.cancel()
        
        activityIndicator.startAnimating()
        mainImageTask = Task { [weak self] in
            guard let self = self else { return }
            
            let image = await dataService.loadImage(from: path, bucket: Bucket.recipes)
            
            guard !Task.isCancelled, let image = image else { return }
            
            ImageCache.shared.setImage(image, for: path)
            photoDish.image = image
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func loadAuthorAvatar(path: String?) {
        guard let path = path else {
            creatorImageView.image = Resources.Images.Icons.profile
            return
        }
        
        // Проверка кэша
        if let cachedImage = ImageCache.shared.image(for: path) {
            creatorImageView.image = cachedImage
            return
        }
        
        avatarImageTask?.cancel()
        avatarImageTask = Task { [weak self] in
            guard let self = self else { return }
            
            let image = await dataService.loadImage(from: path, bucket: Bucket.avatars)
            
            guard !Task.isCancelled, let image = image else { return }
            
            ImageCache.shared.setImage(image, for: path)
            creatorImageView.image = image
        }
    }
    
    let gradientLayer = CAGradientLayer()
    
    private func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.4, 0.9]

        photoDish.layer.addSublayer(gradientLayer)
    }

    private func setupUI() {
        addSubview(photoDish)
        addSubview(creatorStackView)
        setupGradientLayer()
        photoDish.addSubview(ratingContainerView)
        photoDish.addSubview(titleDishLabel)
        
        ratingContainerView.addSubview(ratingImageView)
        ratingContainerView.addSubview(ratingLabel)
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
            
            ratingContainerView.topAnchor.constraint(equalTo: photoDish.topAnchor, constant: Constants.paddingSmall),
            ratingContainerView.leadingAnchor.constraint(equalTo: photoDish.leadingAnchor, constant: Constants.paddingSmall),
            
            
            ratingImageView.leadingAnchor.constraint(equalTo: ratingContainerView.leadingAnchor, constant: Constants.paddingSmall),
            ratingImageView.centerYAnchor.constraint(equalTo: ratingContainerView.centerYAnchor),

            ratingLabel.leadingAnchor.constraint(equalTo: ratingImageView.trailingAnchor, constant: Constants.paddingSmall),
            ratingLabel.centerYAnchor.constraint(equalTo: ratingImageView.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingContainerView.trailingAnchor, constant: -Constants.paddingSmall),

            titleDishLabel.bottomAnchor.constraint(equalTo: photoDish.bottomAnchor, constant: -Constants.paddingSmall),
            titleDishLabel.leadingAnchor.constraint(equalTo: photoDish.leadingAnchor, constant: Constants.paddingSmall),
            titleDishLabel.trailingAnchor.constraint(equalTo: photoDish.trailingAnchor, constant: -Constants.paddingSmall),

            creatorStackView.topAnchor.constraint(equalTo: photoDish.bottomAnchor, constant: Constants.paddingSmall),
            creatorStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.paddingSmall),
            
            creatorImageView.heightAnchor.constraint(equalToConstant: 32),
            creatorImageView.widthAnchor.constraint(equalTo: creatorImageView.heightAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImageTask?.cancel()
        avatarImageTask?.cancel()
        photoDish.image = nil
        creatorImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
}

