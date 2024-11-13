//
//  CreateIngredientsTVCell.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 25.09.2024.
//

import UIKit

class CreateIngredientsTableViewCell: UITableViewCell {
    
//    var itemName : String = ""
//    var itemQuantity : String = ""
    static let id = "ingredients"
    
    private lazy var contentStackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let ingredientName : UITextField = {
        let field = UITextField()
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        field.placeholder = "Название"
        field.font = .helveticalBold(withSize: 16)
        field.backgroundColor = .white
        field.textColor = .black
        field.layer.borderColor = UIColor.orange.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 12
        field.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let weightName : UITextField = {
        let field = UITextField()
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        field.widthAnchor.constraint(equalToConstant: 100).isActive = true
        field.placeholder = "кол-во"
        field.font = .helveticalBold(withSize: 16)
        field.backgroundColor = .white
        field.textColor = .gray
        field.layer.borderColor = UIColor.orange.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 12
        field.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
         super.prepareForReuse()
         self.ingredientName.text = ""
         self.weightName.text = ""
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .neutral10
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(ingredientName)
        contentStackView.addArrangedSubview(weightName)
        ingredientName.setLeftPaddingPoints(15)
        weightName.setLeftPaddingPoints(15)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
    }
    

}

