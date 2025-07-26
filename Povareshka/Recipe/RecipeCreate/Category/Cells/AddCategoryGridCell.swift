//
//  AddCategoryGridCell.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

final class AddCategoryGridCell: UICollectionViewCell {
    static let id = "AddCategoryGridCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        // Настройка иконки
        iconView.image = UIImage(systemName: "plus.circle.fill")
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        // Настройка текста
        titleLabel.text = "Добавить"
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .center
        
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
        backgroundColor = .systemGray5
        layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
