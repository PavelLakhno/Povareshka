//
//  CustomCellView.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 05.09.2024.
//

import UIKit

class CustomViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let id = "CustomViewCell"
    
    private var photoDish = UIImageView(image: "mealImage", cornerRadius: 16)

    private var titleDishLabel = UILabel(text: "Яичница с тостами",
                                         font: .helveticalBold(withSize: 16),
                                         textColor: .black,
                                         numberOfLines: 0)
    
    private var titleTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Ввести название"
        field.backgroundColor = .gray
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private var descriptionTextField: UITextField = {
        let field = UITextField()
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        //field.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -4).isActive = true
        field.font = .helveticalRegular(withSize: 16)
        field.textColor = .black
        field.layer.borderColor = Resources.Colors.orange.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 12
        field.returnKeyType = .done
        field.placeholder = "Ввести описание"
        field.backgroundColor = .gray
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
//    private var creatorStackView = UIStackView(axis: .vertical, aligment: .center, spacing: 8)
//    private var creatorImageView = UIImageView(image: "Martha Stewart", cornerRadius: 16)
    private var creatorLabel = UILabel(text: "Ольга Митрофановна",
                                       font: .helveticalRegular(withSize: 12),
                                       textColor: Resources.Colors.secondary,
                                       numberOfLines: 1)

    func configureCell(with recipe: String) {
        titleDishLabel.text = recipe
    }

    private func setupUI() {
        addSubviews(photoDish, titleTextField, descriptionTextField)

//        creatorStackView.addArrangedSubview(titleDishLabel)
//        creatorStackView.addArrangedSubview(creatorLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoDish.topAnchor.constraint(equalTo: topAnchor),
            photoDish.leadingAnchor.constraint(equalTo: leadingAnchor),
            photoDish.trailingAnchor.constraint(equalTo: trailingAnchor),
            photoDish.heightAnchor.constraint(equalToConstant: 180),
            
            titleTextField.topAnchor.constraint(equalTo: photoDish.bottomAnchor, constant: 30),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),

            descriptionTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 30),
            descriptionTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            descriptionTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),

        ])
    }

}
