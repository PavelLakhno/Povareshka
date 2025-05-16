//
//  StepAddPhotoCell.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 09.10.2024.
//

import UIKit

class StepAddPhotoCell: UITableViewCell {
    
    static let id = "stepAddPhoto"
    
    private let cameraImage : UIImageView = {
        let img = UIImageView()
//        img.clipsToBounds = true
        img.contentMode = .center
        img.image = UIImage(named: "camera")
        img.layer.cornerRadius = 12
        img.layer.borderColor = UIColor.orange.cgColor
        img.layer.borderWidth = 1
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let addPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавить фото"
        label.textColor = UIColor.orange
        label.font = UIFont.helveticalRegular(withSize: 16)
        label.layer.borderColor = UIColor.orange.cgColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.addSubview(cameraImage)
        contentView.addSubview(addPhotoLabel)
        
        NSLayoutConstraint.activate([
            cameraImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cameraImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            cameraImage.widthAnchor.constraint(equalToConstant: 50),
            cameraImage.heightAnchor.constraint(equalToConstant: 50),
            
            addPhotoLabel.leadingAnchor.constraint(equalTo: cameraImage.trailingAnchor, constant: 5),
            addPhotoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            addPhotoLabel.centerYAnchor.constraint(equalTo: cameraImage.centerYAnchor)

        ])
    }
}
