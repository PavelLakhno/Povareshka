//
//  StepPhotoCell.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 26.09.2024.
//

import UIKit

final class StepPhotoCell: UITableViewCell {
    static let id = "StepPhotoCell"
    
    private let recipeImage = UIImageView(
        cornerRadius: Constants.cornerRadiusMedium,
        contentMode: .scaleToFill
    )
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = AppColors.gray100
        contentView.addSubview(recipeImage)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recipeImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingSmall),
            recipeImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingSmall),
        ])
    }
    
    func configure(with image: Data?) {
        recipeImage.image = UIImage(data: image ?? Data())
    }
}
