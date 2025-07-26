//
//  MainIngredientsTVCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import UIKit

class MainIngredientsTableViewCell: UITableViewCell {
    
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
    
    let ingredientName : UILabel = {
        let label = UILabel()
        label.heightAnchor.constraint(equalToConstant: 44).isActive = true
        label.layer.borderColor = UIColor.orange.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 12
        label.font = .helveticalBold(withSize: 16)
        label.backgroundColor = .white
        label.textColor = .black
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    let weightName : UILabel = {
        let label = UILabel()
        label.heightAnchor.constraint(equalToConstant: 44).isActive = true
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.font = .helveticalBold(withSize: 16)
        label.backgroundColor = .white
        label.textColor = .gray
        label.textAlignment = .center
        label.layer.borderColor = UIColor.orange.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
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
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
        ])
    }
    

}
