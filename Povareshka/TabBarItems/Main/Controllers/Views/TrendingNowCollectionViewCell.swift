//
//  TrendingNowCollectionViewCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 28.08.2024.
//

import UIKit
//import Kingfisher

class TrendingNowCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrendingNowCell"
    
    private var mainImageTask: Task<Void, Never>?
    private var avatarImageTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    lazy var photoDish: UIImageView = {
        let image = UIImageView(cornerRadius: 16)
        return image
    }()

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
    
    
    
    lazy var titleDishLabel = UILabel(font: .helveticalBold(withSize: 16),
                                         textColor: .white,
                                         numberOfLines: 0)
    
    private var creatorStackView = UIStackView(axis: .horizontal, aligment: .center, spacing: 8)
    private var creatorImageView = UIImageView(cornerRadius: 16)
    private var creatorLabel = UILabel(font: .helveticalRegular(withSize: 12),
                                       textColor: Resources.Colors.secondary,
                                       numberOfLines: 1)
    

    //SB (optimizated)
    func configure(with recipe: RecipeShortInfo) {
        titleDishLabel.text = recipe.title
        creatorLabel.text = recipe.authorName
       
        loadMainImage(path: recipe.imagePath)
        loadAuthorAvatar(path: recipe.authorAvatarPath)

    }
    
    private func loadMainImage(path: String?) {
        guard let path = path else {
            photoDish.image = UIImage(named: "recipe_placeholder")
            return
        }
        
        // Проверяем кэш
        if let cachedImage = ImageCache.shared.image(for: path) {
            photoDish.image = cachedImage
            return
        }
        mainImageTask?.cancel()
        mainImageTask = Task {
            do {
                let data = try await SupabaseManager.shared.client
                    .storage
                    .from("recipes")
                    .download(path: path)
                
                if !Task.isCancelled, let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: path)
                    photoDish.image = image
                }
            } catch {
                if !Task.isCancelled {
                    photoDish.image = UIImage(named: "placeholder")
                }
            }
        }
    }
    
    private func loadAuthorAvatar(path: String?) {
        guard let path = path else {
            creatorImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }
        
        // Проверка кэша
        if let cachedImage = ImageCache.shared.image(for: path) {
            creatorImageView.image = cachedImage
            return
        }
        
        avatarImageTask?.cancel()
        avatarImageTask = Task {
            do {
                let data = try await SupabaseManager.shared.client
                    .storage
                    .from("avatars")
                    .download(path: path)
                
                if !Task.isCancelled, let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: path)
                    creatorImageView.image = image
                }
            } catch {
                if !Task.isCancelled {
                    creatorImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
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

@MainActor
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
