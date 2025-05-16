//
//  InstructionTableViewCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

class InstructionTableViewCell: UITableViewCell {
    
    static let id = "InstructionCell"
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let descriptionLabel = UILabel()
    private let stepImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        stepImageView.translatesAutoresizingMaskIntoConstraints = false
        stepImageView.contentMode = .scaleToFill
        
        contentView.addSubview(stepLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(stepImageView)
        
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            stepImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            stepImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stepImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.65),
            stepImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stepImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configure(with instruction: InstructionModel) {
        stepLabel.text = "Шаг \(instruction.number)"
        stepLabel.font = .helveticalBold(withSize: 18)
        descriptionLabel.text = instruction.describe
        descriptionLabel.numberOfLines = 0
        if let imageData = instruction.image, let image = UIImage(data: imageData) {
            stepImageView.image = image
        } else {
            stepImageView.image = nil
        }
    }
}

