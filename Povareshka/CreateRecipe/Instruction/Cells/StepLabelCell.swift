//
//  StepLabelCell.swift
//  Povareshka
//
//  Created by user on 09.06.2025.
//

import UIKit

class StepLabelCell: UITableViewCell {
    static let id = "StepLabelCell"
    
    let stepLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticalRegular(withSize: 16)
        label.textColor = .neutral100
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
        
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stepLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stepLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with text: String?) {
        stepLabel.text = text
    }
}
