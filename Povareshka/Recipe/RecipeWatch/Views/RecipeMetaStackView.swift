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

final class RecipeMetaStackView: UIStackView {
    // MARK: - Properties
    private var recipeId: UUID?
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
    func configure(with recipe: RecipeSupabase, averageRating: Double, recipeId: UUID?) {
        self.recipeId = recipeId
        arrangedSubviews.forEach { $0.removeFromSuperview() }

        if let time = recipe.readyInMinutes {
            addMetaItem(icon: Resources.Images.Icons.clockFill, text: "\(time) мин")
        }

        if let servings = recipe.servings {
            addMetaItem(icon: Resources.Images.Icons.fork, text: "\(servings) чел")
        }

        if let difficulty = recipe.difficulty {
            addMetaItem(icon: Resources.Images.Icons.level, text: "\(difficulty)")
        }

        addRatingItem(rating: averageRating)
    }
    
    func updateRating(_ averageRating: Double) {
        arrangedSubviews
            .compactMap { $0 as? RatingView }
            .forEach { $0.configure(with: Int(round(averageRating))) }
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
            icon: Resources.Images.Icons.starFilled,
            text: String(format: "%.1f", rating),
            iconColor: .systemOrange
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRatingTap))
        stack.addGestureRecognizer(tapGesture)
        stack.isUserInteractionEnabled = true
        
        addArrangedSubview(stack)
    }
    
    private func createIconLabelStack(icon: UIImage?,
                                      text: String,
                                      iconColor: UIColor = Resources.Colors.orange) -> UIStackView {
        let stack = UIStackView(axis: .horizontal, alignment: .center, spacing: Constants.spacingSmall)
        let iconView = UIImageView(image: icon?.withTintColor(iconColor, renderingMode: .alwaysOriginal),
                                   cornerRadius: 0,
                                   contentMode: .scaleAspectFit)
        
        
        let label = UILabel(
            text: text, font: .helveticalLight(withSize: 14),
            textColor: Resources.Colors.titleGray
        )
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        return stack
    }
}

extension RecipeMetaStackView {
    @objc private func handleRatingTap() {
        guard let recipeId = recipeId else { return }
        delegate?.didTapRatingView(recipeId: recipeId)
    }
}
