//
//  RatingView.swift
//  Povareshka
//
//  Created by user on 22.07.2025.
//

import UIKit

final class RatingView: UIView {
    private var stars: [UIButton] = []
    var didSelectRating: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...5 {
            let button = UIButton()
            button.tag = i
            button.tintColor = .systemOrange
            button.setImage(Resources.Images.Icons.starEmpty, for: .normal)
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            stars.append(button)
            stack.addArrangedSubview(button)
        }
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with rating: Int) {
        for (index, star) in stars.enumerated() {
            let image = index < rating ?
            Resources.Images.Icons.starFilled :
            Resources.Images.Icons.starEmpty
            star.setImage(image, for: .normal)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        configure(with: rating)
        didSelectRating?(rating)
    }
}


//final class AddPhotoCell: UICollectionViewCell {
//    var addHandler: (() -> Void)?
//    
//    private let addButton = UIButton()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    private func setupView() {
//
//        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
//        addButton.tintColor = .systemOrange
//        addButton.backgroundColor = .systemBackground
//        addButton.layer.cornerRadius = 8
//        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
//        contentView.addSubview(addButton)
//        
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            addButton.topAnchor.constraint(equalTo: contentView.topAnchor),
//            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//    }
//    
//    @objc private func addTapped() {
//        addHandler?()
//    }
//}

final class AddPhotoCell: UICollectionViewCell {
    static let id = "AddPhotoCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    var addHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGesture()
    }
    
    private func setupViews() {
        // Настройка иконки
        iconView.image = UIImage(systemName: "plus.circle.fill")
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        // Настройка текста
        titleLabel.text = "Добавить"
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .systemGray
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
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tap)
        contentView.isUserInteractionEnabled = true
    }
    
    @objc private func cellTapped() {
        addHandler?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
