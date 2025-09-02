//
//  StepLabelCell.swift
//  Povareshka
//
//  Created by user on 09.06.2025.
//

import UIKit

final class StepLabelCell: UITableViewCell {
    static let id = "StepLabelCell"
    
    private let stepLabel = UILabel(
        font: .helveticalRegular(withSize: 16),
        textColor: .black
    )
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = Constants.cornerRadiusSmall
        contentView.addSubview(stepLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingMedium),
            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            stepLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            stepLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingMedium)
        ])
    }
    
    func configure(with text: String?) {
        stepLabel.text = text
    }
}
