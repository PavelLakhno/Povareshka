//
//  RecipeMetaStackView.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit

// For watch feedbacks
protocol RecipeMetaStackViewDelegate: AnyObject {
    func didTapRatingView(recipeId: UUID)
}

// MARK: - Universal Meta Stack View
final class UniversalRecipeMetaStackView: UIStackView {
    
    // MARK: - Properties
    private var recipeId: UUID?
    private var isOnline: Bool = true
    weak var delegate: RecipeMetaStackViewDelegate?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public Methods
    func configure(with metaData: RecipeMetaData, averageRating: Double, recipeId: UUID?, isOnline: Bool) {
        self.recipeId = recipeId
        self.isOnline = isOnline
        arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let time = metaData.readyInMinutes {
            addMetaItem(icon: AppImages.Icons.clockFill, text: "\(time) мин")
        }

        if let servings = metaData.servings {
            addMetaItem(icon: AppImages.Icons.fork, text: "\(servings) чел")
        }

        if let difficulty = metaData.difficulty {
            addMetaItem(icon: AppImages.Icons.level, text: "\(difficulty)")
        }

        if isOnline {
            addRatingItem(rating: averageRating)
        } else {
            addOfflineItem()
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        axis = .horizontal
        distribution = .equalSpacing
        spacing = Constants.spacingMedium
        alignment = .center
    }
    
    private func addMetaItem(icon: UIImage?, text: String) {
        let stack = createIconLabelStack(icon: icon, text: text)
        addArrangedSubview(stack)
    }
    
    private func addRatingItem(rating: Double) {
        let stack = createIconLabelStack(
            icon: AppImages.Icons.starFilled,
            text: String(format: "%.1f", rating),
            iconColor: AppColors.primaryOrange
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRatingTap))
        stack.addGestureRecognizer(tapGesture)
        stack.isUserInteractionEnabled = true
        
        addArrangedSubview(stack)
    }
    
    private func addOfflineItem() {
        let stack = createIconLabelStack(
            icon: AppImages.Icons.wifi,
            text: "OFF",
            iconColor: .systemGray
        )
        addArrangedSubview(stack)
    }
    
    private func createIconLabelStack(icon: UIImage?, text: String, iconColor: UIColor = AppColors.primaryOrange) -> UIStackView {
        let stack = UIStackView(axis: .horizontal, alignment: .center, spacing: Constants.spacingSmall)
        let iconView = UIImageView(
            image: icon?.withTintColor(iconColor, renderingMode: .alwaysOriginal),
            cornerRadius: 0,
            contentMode: .scaleAspectFit
        )
        
        let label = UILabel(
            text: text,
            font: .helveticalLight(withSize: 14),
            textColor: .black
        )
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        return stack
    }
    
    @objc private func handleRatingTap() {
        guard let recipeId = recipeId, isOnline else { return }
        delegate?.didTapRatingView(recipeId: recipeId)
    }
}
