//
//  CategoryCell.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

final class CategoryCell: UITableViewCell {
    static let id = "CategoryCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let checkmarkView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    private func setupViews() {
        // Настройка иконки
        
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        
        // Настройка текста
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        // Настройка чекбокса
        checkmarkView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkView.tintColor = .systemOrange
        checkmarkView.contentMode = .scaleAspectFit
        
        // Контейнер
        let stackView = UIStackView(arrangedSubviews: [iconView, titleLabel, UIView(), checkmarkView])
        stackView.spacing = 16
        stackView.alignment = .center
        contentView.addSubview(stackView)
        
        // Констрейнты
        iconView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            checkmarkView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkView.heightAnchor.constraint(equalToConstant: 24),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with category: RecipeCategory) {
        iconView.image = UIImage(named: category.iconName)?.withRenderingMode(.alwaysTemplate)
//        UIImage(systemName: category.iconName)
        titleLabel.text = category.title
        checkmarkView.isHidden = !category.isSelected
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
