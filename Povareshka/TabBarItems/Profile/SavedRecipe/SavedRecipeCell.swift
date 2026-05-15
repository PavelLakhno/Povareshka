//
//  SavedRecipeCell.swift
//  Povareshka
//
//  Created by user on 30.10.2025.
//

import UIKit
import Kingfisher

final class RecipeListCell: UITableViewCell {
    static let id = "RecipeListCell"

    private let dataService = DataService.shared
    private var imageLoadTask: Task<Void, Never>?

    // MARK: - UI Components
    private lazy var recipeImageView = UIImageView(
        image: AppImages.Icons.cameraMain,
        size: CGSize(width: 70, height: 70),
        cornerRadius: Constants.cornerRadiusMedium,
        contentMode: .scaleAspectFill,
        backgroundColor: AppColors.gray100
    )

    private let titleLabel = UILabel(
        font: .helveticalBold(withSize: 16),
        textColor: .label,
        numberOfLines: 2
    )

    private let metaLabel = UILabel(
        font: .helveticalRegular(withSize: 14),
        textColor: .secondaryLabel,
        numberOfLines: 1
    )

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(metaLabel)
        accessoryType = .disclosureIndicator
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recipeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            recipeImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            recipeImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            metaLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Configure (Realm)
    func configure(with recipe: RecipeModel) {
        titleLabel.text = recipe.title

        var parts: [String] = []
        if let time = recipe.readyInMinutes { parts.append("\(time) мин") }
        if let servings = recipe.servings, servings > 0 { parts.append("\(servings) порц") }
        metaLabel.text = parts.joined(separator: " • ")

        recipeImageView.image = recipe.imageData.flatMap(UIImage.init) ?? AppImages.Icons.cameraMain
    }

    // MARK: - Configure (Supabase)
    func configure(with recipe: RecipeShortInfo) {
        titleLabel.text = recipe.title

        var parts: [String] = []
        if let time = recipe.readyInMinutes, time > 0 { parts.append("\(time) мин") }
        parts.append(recipe.authorName)
        metaLabel.text = parts.joined(separator: " • ")

        loadImage(path: recipe.imagePath)
    }

    private func loadImage(path: String?) {
        recipeImageView.kf.cancelDownloadTask()
        imageLoadTask?.cancel()
        recipeImageView.image = nil

        guard let path else {
            recipeImageView.image = AppImages.Icons.cameraMain
            return
        }

        imageLoadTask = Task {
            do {
                let url = try await dataService.getImageURL(for: path, bucket: Bucket.recipes)
                guard !Task.isCancelled else { return }
                await MainActor.run { () -> Void in
                    recipeImageView.kf.setImage(
                        with: url,
                        placeholder: AppImages.Icons.cameraMain,
                        options: [.transition(.fade(0.3)), .scaleFactor(UIScreen.main.scale), .cacheOriginalImage]
                    )
                }
            } catch {
                await MainActor.run { recipeImageView.image = AppImages.Icons.cameraMain }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        recipeImageView.kf.cancelDownloadTask()
        recipeImageView.image = nil
        titleLabel.text = nil
        metaLabel.text = nil
    }
}
