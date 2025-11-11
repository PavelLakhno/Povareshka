//
//  SavedRecipeCell.swift
//  Povareshka
//
//  Created by user on 30.10.2025.
//

import UIKit

class SavedRecipeCell: UITableViewCell {
    static let id = "SavedRecipeCell"
    
    // MARK: - UI Components
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = AppColors.gray100
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let offlineBadge: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.gray200
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Офлайн"
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2)
        ])
        
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(metaLabel)
        contentView.addSubview(offlineBadge)
        
        accessoryType = .disclosureIndicator
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recipeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: 70),
            recipeImageView.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            offlineBadge.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 6),
            offlineBadge.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            offlineBadge.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(with recipe: RecipeModel) {
        titleLabel.text = recipe.title
        
        // Формируем мета-информацию
        var metaParts: [String] = []
        
        if let readyInMinutes = recipe.readyInMinutes {
            metaParts.append("\(readyInMinutes) мин")
        }
        
        if recipe.servings ?? 0 > 0 {
            metaParts.append("\(recipe.servings ?? 0) порц")
        }
        
        metaLabel.text = metaParts.joined(separator: " • ")
        
        // Загружаем изображение
        if let imageData = recipe.imageData {
            recipeImageView.image = UIImage(data: imageData)
        } else {
            recipeImageView.image = UIImage(systemName: "photo")?
                .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recipeImageView.image = nil
        titleLabel.text = nil
        metaLabel.text = nil
    }
}
