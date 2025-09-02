//
//  InstructionTextCell.swift
//  Povareshka
//
//  Created by user on 11.06.2025.
//

import UIKit

class InstructionTextCell: UITableViewCell {
    static let id = "InstructionTextCell"
    
    private let stepLabel = UILabel(font: .helveticalBold(withSize: 18), textColor: .black)
    private let descriptionLabel = UILabel(font: .helveticalRegular(withSize: 16), textColor: .black, numberOfLines: 0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(stepLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingMedium),
            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingSmall),
            stepLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingSmall),
            
            descriptionLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: Constants.paddingMedium),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingSmall),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingSmall),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingMedium)
        ])
    }
    
    func configure(stepNumber: Int, description: String) {
        stepLabel.text = "Шаг \(stepNumber)"
        descriptionLabel.text = description
    }
}
