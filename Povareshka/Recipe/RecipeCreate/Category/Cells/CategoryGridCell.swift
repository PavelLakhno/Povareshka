//
//  CategoryGridCell.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

final class CategoryGridCell: UICollectionViewCell {
    static let id = "CategoryGridCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        // Настройка иконки
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemOrange
        
        // Настройка текста
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        // Вертикальный стек
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        contentView.addSubview(stack)
        
        // Констрейнты
        stack.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
        
        // Стиль ячейки
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
    }
    
    func configure(with category: String, iconName: String, isSelected: Bool) {
        titleLabel.text = category
        iconView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        
        // Стиль для выбранного состояния
        backgroundColor = isSelected ? .systemOrange.withAlphaComponent(0.2) : .systemGray6
        layer.borderWidth = isSelected ? 1 : 0
        layer.borderColor = isSelected ? UIColor.systemOrange.cgColor : UIColor.clear.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
