//
//  RecipeMetaStackView.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit

// Добавим протокол делегата
protocol RecipeMetaStackViewDelegate: AnyObject {
    func didTapRatingView(recipeId: UUID)
}

final class RecipeMetaStackView: UIStackView {
    private var averageRating: Double = 0
    private var recipeId: UUID?
    weak var delegate: RecipeMetaStackViewDelegate? // Для перехода к экрану отзывов
    
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
        self.averageRating = averageRating
        self.recipeId = recipeId
        // Очищаем предыдущие вью
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Время приготовления
        if let time = recipe.readyInMinutes {
            addMetaItem(iconName: "clock", text: "\(time) мин")
        }
        
        // Количество порций
        if let servings = recipe.servings {
            addMetaItem(iconName: "fork.knife", text: "\(servings) чел")
        }
        
        if let difficulty = recipe.difficulty {
            addMetaItem(iconName: Resources.Images.Icons.level, text: "\(difficulty)")
        }
        
        // Рейтинг с возможностью тапа
        let ratingStack = createIconLabelStack(
            iconName: "star.fill",
            text: String(format: "%.1f", averageRating),
            iconColor: .systemOrange
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRatingTap))
        ratingStack.addGestureRecognizer(tapGesture)
        ratingStack.isUserInteractionEnabled = true
        
        addArrangedSubview(ratingStack)

    }
    
    func addMetaItem(iconName: String, text: String, iconColor: UIColor = .systemOrange) {
        let stack = createIconLabelStack(iconName: iconName, text: text, iconColor: iconColor)
        addArrangedSubview(stack)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        axis = .horizontal
        distribution = .equalSpacing
        spacing = 8
        alignment = .center
    }
    
    func updateRating(_ averageRating: Double) {
        // Добавляем или обновляем отображение рейтинга
        if let ratingView = arrangedSubviews.first(where: { $0 is RatingView }) as? RatingView {
            ratingView.configure(with: Int(round(averageRating)))
        } else {
            let ratingView = RatingView()
            ratingView.configure(with: Int(round(averageRating)))
            ratingView.isUserInteractionEnabled = false
            insertArrangedSubview(ratingView, at: 0)
        }
    }
    
    private func createIconLabelStack(iconName: String, text: String, iconColor: UIColor) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        
        let icon = UIImage(systemName: iconName)?
            .withTintColor(iconColor, renderingMode: .alwaysOriginal)
        
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        return stack
    }
    
    @objc private func handleRatingTap() {
        guard let recipeId = recipeId else { return }
        delegate?.didTapRatingView(recipeId: recipeId)
    }
}
