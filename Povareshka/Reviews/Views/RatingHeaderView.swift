//
//  RatingHeaderView.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

class RatingHeaderView: UIView {
    private let ratingLabel = UILabel()
    private let starsView = UIStackView()
    private let titleLabel = UILabel()
    private let horizontalStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(rating: Double) {
        ratingLabel.text = String(format: "%.1f", rating)
        
        // Очищаем предыдущие звезды
        starsView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Добавляем звезды (5 штук)
        for i in 1...5 {
            let star = UIImageView(image: UIImage(systemName: i <= Int(rating) ? "star.fill" : "star"))
            star.tintColor = .systemOrange
            star.contentMode = .scaleAspectFit
            star.widthAnchor.constraint(equalToConstant: 16).isActive = true
            star.heightAnchor.constraint(equalToConstant: 16).isActive = true
            starsView.addArrangedSubview(star)
        }
    }
    
    private func setupView() {
        // Настройка ratingLabel
        ratingLabel.font = .boldSystemFont(ofSize: 30)
        ratingLabel.textAlignment = .left
        
        // Настройка starsView
        starsView.axis = .horizontal
        starsView.spacing = 4
        starsView.alignment = .leading
        
        // Настройка titleLabel
        titleLabel.text = "Мнение пользователей"
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .left
        
        // Вертикальный стек для звезд и заголовка
        let rightStack = UIStackView(arrangedSubviews: [starsView, titleLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .leading
        
        // Горизонтальный стек для оценки и правой части
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        horizontalStack.alignment = .center
        horizontalStack.addArrangedSubview(ratingLabel)
        horizontalStack.addArrangedSubview(rightStack)
        
        addSubview(horizontalStack)
        
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            horizontalStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            horizontalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}

