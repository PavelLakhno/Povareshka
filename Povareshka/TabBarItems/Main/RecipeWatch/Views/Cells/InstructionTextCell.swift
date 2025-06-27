//
//  InstructionTextCell.swift
//  Povareshka
//
//  Created by user on 11.06.2025.
//

import UIKit

class InstructionTextCell: UITableViewCell {
    static let id = "InstructionTextCell"
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticalBold(withSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(stepLabel)
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            stepLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            descriptionLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(stepNumber: Int, description: String) {
        stepLabel.text = "Шаг \(stepNumber)"
        descriptionLabel.text = description
    }
}
