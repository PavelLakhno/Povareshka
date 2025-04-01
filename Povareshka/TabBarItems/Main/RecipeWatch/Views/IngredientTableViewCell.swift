//
//  IngredientTableViewCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    
    static let id = "IngredientTableViewCell"
    
    // MARK: - UI Elements
    lazy var titleLabel : UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.font = .helveticalBold(withSize: 16)
        lb.textColor = .neutral100
        lb.textAlignment = .left
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    lazy var countLabel : UILabel = {
        let lb = UILabel()
        lb.font = .helveticalRegular(withSize: 16)
        lb.textColor = .neutral100
        lb.textAlignment = .right
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
        
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
     private func setupCell() {
        selectionStyle = .none
        backgroundColor = .neutral10
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
}
