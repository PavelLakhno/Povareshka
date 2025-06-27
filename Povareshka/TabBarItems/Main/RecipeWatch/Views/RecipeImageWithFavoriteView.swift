//
//  RecipeImageWithFavoriteView.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit

final class RecipeImageWithFavoriteView: UIView {
    
    // MARK: - Properties
    private let imageView = UIImageView()
    private let favoriteButton = UIButton()
    private var isFavorite = false
    private var isCreator = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public Methods
    func configure(with image: UIImage?, isFavorite: Bool, isCreator: Bool) {
        imageView.image = image
        self.isFavorite = isFavorite
        self.isCreator = isCreator
        updateFavoriteButton()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        // Настройка imageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        addSubview(imageView)
        
        // Настройка кнопки
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        favoriteButton.tintColor = .white
        favoriteButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        favoriteButton.layer.cornerRadius = 15
        addSubview(favoriteButton)
        
        // Констрейнты
        imageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func updateFavoriteButton() {
        if isCreator {
            favoriteButton.isHidden = true
        } else {
            favoriteButton.isHidden = false
            favoriteButton.tintColor = isFavorite ? .systemOrange : .white
        }
    }
    
    @objc private func favoriteButtonTapped() {
        isFavorite.toggle()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = .identity
            }
        }

        updateFavoriteButton()
        
        // Здесь можно добавить логику сохранения состояния в базу данных
    }
}
