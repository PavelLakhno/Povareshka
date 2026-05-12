//
//  RecipeImageWithFavoriteView.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit

final class RecipeImageWithFavoriteView: UIView {
    
    // MARK: - Properties
    private let dataService = DataService.shared
    private let imageView = UIImageView(cornerRadius: Constants.cornerRadiusBig, contentMode: .scaleAspectFill)
    private lazy var favoriteButton = UIButton(image: AppImages.Icons.favorite,
                                               backgroundColor: .black.withAlphaComponent(0.3),
                                               cornerRadius: Constants.cornerRadiusMedium,
                                               size: Constants.viewSize30,
                                               target: self,
                                               action: #selector(favoriteButtonTapped))
    private var isFavorite = false
    private var isCreator = false
    private var showFavoriteButton = true
    private var recipeId: UUID?
    private weak var parentViewController: UIViewController?
    
    var favoriteStatusChanged: ((Bool) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    // MARK: - Public Methods
    func configure(with image: UIImage? = AppImages.Icons.cameraMain,
                   isFavorite: Bool,
                   isCreator: Bool,
                   recipeId: UUID?,
                   parentViewController: UIViewController?, showFavoriteButton: Bool = true) {
        imageView.image = image
        self.isFavorite = isFavorite
        self.isCreator = isCreator
        self.recipeId = recipeId
        self.parentViewController = parentViewController
        self.showFavoriteButton = showFavoriteButton
        updateFavoriteButton()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        addSubview(imageView)
        addSubview(favoriteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.paddingMedium),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.paddingMedium),
        ])
    }
    
    private func updateFavoriteButton() {
        if isCreator || !showFavoriteButton {
            favoriteButton.isHidden = true
        } else {
            favoriteButton.isHidden = false
            favoriteButton.tintColor = isFavorite ? AppColors.primaryOrange : .white
        }
    }
    
    @objc private func favoriteButtonTapped() {
        guard let recipeId = recipeId else { return }
        
        guard let parentVC = parentViewController else { return }
        
        Task {
            do {
                let newFavoriteState = try await dataService.toggleFavorite(
                                    recipeId: recipeId,
                                    isCurrentlyFavorite: isFavorite
                                )
                
                DispatchQueue.main.async {
                    self.isFavorite = newFavoriteState
                    self.animateButton()
                    self.updateFavoriteButton()
                    self.favoriteStatusChanged?(self.isFavorite)
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.shared.showError(on: parentVC, error: error)
                }
            }
        }
    }
    
    private func animateButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.favoriteButton.transform = .identity
            }
        }
    }
}

