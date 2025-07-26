//
//  StepPhotoCell.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 26.09.2024.
//

import UIKit

class StepPhotoCell: UITableViewCell {
    
    static let id = "stepPhoto"
    
    lazy var recipeImage : UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleToFill
        img.layer.cornerRadius = 12
        img.layer.borderColor = UIColor.clear.cgColor
        img.layer.borderWidth = 1
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .neutral10
        contentView.addSubview(recipeImage)
        
        NSLayoutConstraint.activate([
            recipeImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            recipeImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

        ])
    }
}
