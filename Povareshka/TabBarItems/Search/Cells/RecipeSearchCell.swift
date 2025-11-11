//
//  RecipeSearchCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 13.03.2025.
//

import UIKit
import Kingfisher

final class RecipeSearchCell: UICollectionViewCell {
    static let id = "RecipeSearchCell"
    
    private let dataService = DataService.shared
    
    // MARK: - UI Components
    private lazy var mainImageActivityIndicator = UIActivityIndicatorView.createIndicator(style: .medium, centerIn: recipeImageView)
    
    private lazy var recipeImageView = UIImageView(
        cornerRadius: Constants.cornerRadiusMedium,
        contentMode: .scaleAspectFill
    )
    
    private let timeContainerView = UIView(
        backgroundColor: .black.withAlphaComponent(0.6),
        cornerRadius: Constants.cornerRadiusSmall
    )
    
    private let timeIconImageView = UIImageView(
        image: AppImages.Icons.clockEmpty,
        size: Constants.viewSize15,
        tintColor: .white,
        backgroundColor: .clear
    )
    
    private let timeLabel = UILabel(
        font: .systemFont(ofSize: 12, weight: .medium),
        textColor: .white,
        textAlignment: .center,
        numberOfLines: 1
    )
    
    // Контейнер для избранного (только отображение)
    private let favoritesContainerView = UIView(
        backgroundColor: .black.withAlphaComponent(0.6),
        cornerRadius: Constants.cornerRadiusSmall
    )
    
    private let favoritesIconImageView = UIImageView(
        image: AppImages.Icons.favorite, // Всегда заполненное сердце
        size: Constants.viewSize15,
        tintColor: .white,
        backgroundColor: .clear
    )
    
    private let favoritesCountLabel = UILabel(
        font: .systemFont(ofSize: 12, weight: .medium),
        textColor: .white,
        textAlignment: .center,
        numberOfLines: 1
    )
    
    private let titleLabel = UILabel(
        font: .systemFont(ofSize: 14, weight: .semibold),
        textColor: .label,
        numberOfLines: 2
    )
    
//    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    private var currentRecipeId: UUID?
    private var favoritesTask: Task<Void, Never>?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
//        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with recipe: RecipeShortInfo) {
        titleLabel.text = recipe.title
        currentRecipeId = recipe.id
        
        // Устанавливаем время приготовления если есть
        if let cookingTime = recipe.readyInMinutes, cookingTime > 0 {
            timeLabel.text = "\(cookingTime) мин"
            timeContainerView.isHidden = false
        } else {
            timeContainerView.isHidden = true
        }
        
        loadRecipeImage(path: recipe.imagePath)
        loadFavoritesCount(recipeId: recipe.id)
    }
    
    // MARK: - Image Loading
    private func loadRecipeImage(path: String?) {
        // Очищаем imageView
        recipeImageView.image = nil
        recipeImageView.kf.cancelDownloadTask()
        
        guard let path = path else {
            recipeImageView.image = AppImages.Icons.cameraMain
            return
        }
        
        mainImageActivityIndicator.startAnimating()
        
        Task {
            do {
                let url = try await dataService.getImageURL(for: path, bucket: Bucket.recipes)
                
                DispatchQueue.main.async {
                    self.recipeImageView.kf.setImage(
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
                        }
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.mainImageActivityIndicator.stopAnimating()
                    self.recipeImageView.image = AppImages.Icons.cameraMain
                    print("❌ Ошибка загрузки изображения рецепта: \(error)")
                }
            }
        }
    }
    
    // MARK: - Favorites Count Loading
    private func loadFavoritesCount(recipeId: UUID) {
        // Отменяем предыдущую задачу
        favoritesTask?.cancel()
        
        favoritesTask = Task {
            do {
                // Загружаем только количество добавлений в избранное
                let favoritesCount = try await dataService.getFavoritesCount(recipeId: recipeId)
                
                // Проверяем, не отменена ли задача и ячейка все еще отображает тот же рецепт
                if !Task.isCancelled, self.currentRecipeId == recipeId {
                    await MainActor.run {
                        self.updateFavoritesCountUI(count: favoritesCount)
                    }
                }
            } catch {
                print("❌ Ошибка загрузки количества избранного: \(error)")
                // В случае ошибки скрываем контейнер
                if !Task.isCancelled, self.currentRecipeId == recipeId {
                    await MainActor.run {
                        self.favoritesContainerView.isHidden = true
                    }
                }
            }
        }
    }
    
    @MainActor
    private func updateFavoritesCountUI(count: Int) {
        // Если нет добавлений в избранное - скрываем контейнер
        guard count > 0 else {
            favoritesContainerView.isHidden = true
            return
        }
        
        favoritesContainerView.isHidden = false
        favoritesCountLabel.text = "\(count)"
        
        // Всегда показываем заполненное сердце (не зависит от статуса текущего пользователя)
        favoritesIconImageView.image = AppImages.Icons.favorite
        favoritesIconImageView.tintColor = .white
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)
        recipeImageView.addSubview(timeContainerView)
        recipeImageView.addSubview(favoritesContainerView)
        
        timeContainerView.addSubview(timeIconImageView)
        timeContainerView.addSubview(timeLabel)
        
        favoritesContainerView.addSubview(favoritesIconImageView)
        favoritesContainerView.addSubview(favoritesCountLabel)
        
        // Делаем контейнер неинтерактивным
        favoritesContainerView.isUserInteractionEnabled = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Recipe Image View - квадратная
            recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeImageView.heightAnchor.constraint(equalTo: recipeImageView.widthAnchor),
            
            // Time Container - в левом нижнем углу изображения
            timeContainerView.leadingAnchor.constraint(equalTo: recipeImageView.leadingAnchor, constant: Constants.paddingSmall),
            timeContainerView.bottomAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: -Constants.paddingSmall),
            
            // Time Icon
            timeIconImageView.leadingAnchor.constraint(equalTo: timeContainerView.leadingAnchor, constant: Constants.spacingMedium),
            timeIconImageView.centerYAnchor.constraint(equalTo: timeContainerView.centerYAnchor),
            
            // Time Label
            timeLabel.leadingAnchor.constraint(equalTo: timeIconImageView.trailingAnchor, constant: Constants.spacingSmall),
            timeLabel.trailingAnchor.constraint(equalTo: timeContainerView.trailingAnchor, constant: -Constants.spacingMedium),
            timeLabel.topAnchor.constraint(equalTo: timeContainerView.topAnchor, constant: Constants.spacingSmall),
            timeLabel.bottomAnchor.constraint(equalTo: timeContainerView.bottomAnchor, constant: -Constants.spacingSmall),
            
            // Favorites Container - в правом верхнем углу изображения
            favoritesContainerView.topAnchor.constraint(equalTo: recipeImageView.topAnchor, constant: Constants.paddingSmall),
            favoritesContainerView.trailingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: -Constants.paddingSmall),
            
            // Favorites Icon
            favoritesIconImageView.leadingAnchor.constraint(equalTo: favoritesContainerView.leadingAnchor, constant: Constants.spacingMedium),
            favoritesIconImageView.centerYAnchor.constraint(equalTo: favoritesContainerView.centerYAnchor),
            
            // Favorites Count Label
            favoritesCountLabel.leadingAnchor.constraint(equalTo: favoritesIconImageView.trailingAnchor, constant: Constants.spacingSmall),
            favoritesCountLabel.trailingAnchor.constraint(equalTo: favoritesContainerView.trailingAnchor, constant: -Constants.spacingMedium),
            favoritesCountLabel.topAnchor.constraint(equalTo: favoritesContainerView.topAnchor, constant: Constants.spacingSmall),
            favoritesCountLabel.bottomAnchor.constraint(equalTo: favoritesContainerView.bottomAnchor, constant: -Constants.spacingSmall),
            
            // Title Label - под изображением
            titleLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: Constants.spacingMedium),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Отменяем все загрузки Kingfisher
        recipeImageView.kf.cancelDownloadTask()
        
        // Отменяем задачу загрузки количества избранного
        favoritesTask?.cancel()
        favoritesTask = nil
        
        // Останавливаем индикаторы
        mainImageActivityIndicator.stopAnimating()
        
        // Очищаем изображения
        recipeImageView.image = nil
        
        // Сбрасываем текст
        titleLabel.text = ""
        timeLabel.text = ""
        favoritesCountLabel.text = ""
        
        // Сбрасываем состояние
        currentRecipeId = nil
        favoritesContainerView.isHidden = true
        timeContainerView.isHidden = true
    }
}
