//
//  RecipeMetaStackView.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit

final class RecipeMetaStackView: UIStackView {
    
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
    func configure(with recipe: RecipeSupabase) {
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
        
        // Рейтинг
//        if let rating = recipe.rating {
        addMetaItem(iconName: "star.fill", text: String(format: "%.1f", 5.0))
//        }
//        if let comments = recipe.comments {
        addMetaItem(iconName: "message.fill", text: "34")
        //        }
    }
    
    func addMetaItem(iconName: String, text: String, iconColor: UIColor = .systemOrange) {
        let stack = createIconLabelStack(iconName: iconName, text: text, iconColor: iconColor)
        addArrangedSubview(stack)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = 8
        alignment = .center
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
}
