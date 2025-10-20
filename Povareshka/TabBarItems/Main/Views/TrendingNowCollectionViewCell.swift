//
//  TrendingNowCollectionViewCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 28.08.2024.
//

import UIKit
import Kingfisher

final class TrendingNowCollectionViewCell: UICollectionViewCell {
    static let id = "TrendingNowCell"
    
    private let dataService = DataService.shared
    
    private lazy var mainImageActivityIndicator = UIActivityIndicatorView.createIndicator(style: .medium, centerIn: photoDish)
    private lazy var avatarActivityIndicator = UIActivityIndicatorView.createIndicator(style: .medium, centerIn: creatorImageView)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupIndicators()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var photoDish = UIImageView(
        cornerRadius: Constants.cornerRadiusMedium,
        contentMode: .scaleToFill
    )

    private var ratingContainerView = UIView(
        backgroundColor: .black.withAlphaComponent(0.3),
        cornerRadius: Constants.cornerRadiusSmall
    )
    
    private var ratingImageView = UIImageView(
        image: AppImages.Icons.starFilled?.withTintColor(.systemYellow,
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
        textColor: AppColors.gray600,
        numberOfLines: 1
    )

    // MARK: - Configuration
    func configure(with recipe: RecipeShortInfo) {
        titleDishLabel.text = recipe.title
        creatorLabel.text = recipe.authorName
        
        loadMainImage(path: recipe.imagePath)
        loadAuthorAvatar(path: recipe.authorAvatarPath)
        
        Task {
            do {
                let averageRating = try await dataService.fetchAverageRating(recipeId: recipe.id)
                ratingLabel.text = String(format: "%.1f", averageRating)
            } catch {
                print("Ошибка загрузки рейтинга: \(error)")
                ratingLabel.text = "0.0"
            }
        }
    }
    
    // MARK: - Image Loading with Kingfisher
    private func loadMainImage(path: String?) {
        // clean imageView
        photoDish.image = nil
        photoDish.kf.cancelDownloadTask()
        
        guard let path = path else {
            photoDish.image = AppImages.Icons.cameraMain
            return
        }
        
        mainImageActivityIndicator.startAnimating()
        
        Task {
            do {
                let url = try await dataService.getImageURL(for: path, bucket: Bucket.recipes)
                
                DispatchQueue.main.async {
                    self.photoDish.kf.setImage(
                        with: url,
                        placeholder: AppImages.Icons.cameraMain,
                        options: [
                            .transition(.fade(0.3)),
                            .scaleFactor(UIScreen.main.scale),
                            .cacheOriginalImage,
                            .targetCache(ImageCache.default)
                        ],
                        completionHandler: { result in
                            self.mainImageActivityIndicator.stopAnimating()
                            
                            switch result {
                            case .success(let value):
                                print("✅ Основное изображение загружено: \(value.source.url?.absoluteString ?? "")")
                            case .failure(let error):
                                print("❌ Ошибка загрузки основного изображения: \(error)")
                                self.photoDish.image = AppImages.Icons.cameraMain
                            }
                        }
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.mainImageActivityIndicator.stopAnimating()
                    self.photoDish.image = AppImages.Icons.cameraMain
                    print("❌ Ошибка получения URL основного изображения: \(error)")
                }
            }
        }
    }
    
    private func loadAuthorAvatar(path: String?) {
        // clean imageView
        creatorImageView.image = nil
        creatorImageView.kf.cancelDownloadTask()
        
        guard let path = path else {
            creatorImageView.image = AppImages.Icons.avatar
            return
        }
        
        avatarActivityIndicator.startAnimating()
        
        Task {
            do {
                let url = try await dataService.getImageURL(for: path, bucket: Bucket.avatars)
                
                DispatchQueue.main.async {
                    self.creatorImageView.kf.setImage(
                        with: url,
                        placeholder: AppImages.Icons.avatar,
                        options: [
                            .transition(.fade(0.3)),
                            .scaleFactor(UIScreen.main.scale),
                            .cacheOriginalImage,
                            .targetCache(ImageCache.default)
                        ],
                        completionHandler: { result in
                            self.avatarActivityIndicator.stopAnimating()
                            
                            switch result {
                            case .success(let value):
                                print("✅ Аватар загружен: \(value.source.url?.absoluteString ?? "")")
                            case .failure(let error):
                                print("❌ Ошибка загрузки аватара: \(error)")
                                self.creatorImageView.image = AppImages.Icons.avatar
                            }
                        }
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.avatarActivityIndicator.stopAnimating()
                    self.creatorImageView.image = AppImages.Icons.avatar
                    print("❌ Ошибка получения URL аватара: \(error)")
                }
            }
        }
    }
    
    // MARK: - Setup
    private func setupIndicators() {
        photoDish.addSubview(mainImageActivityIndicator)
        creatorImageView.addSubview(avatarActivityIndicator)
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
        // ... ваши существующие констрейнты без изменений ...
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
        
        // Отменяем все загрузки Kingfisher :cite[3]
        photoDish.kf.cancelDownloadTask()
        creatorImageView.kf.cancelDownloadTask()
        
        // Останавливаем индикаторы
        mainImageActivityIndicator.stopAnimating()
        avatarActivityIndicator.stopAnimating()
        
        // Очищаем изображения
        photoDish.image = nil
        creatorImageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
