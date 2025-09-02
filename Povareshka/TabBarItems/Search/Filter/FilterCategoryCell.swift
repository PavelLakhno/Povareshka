//
//  FilterCategoryCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.03.2025.
//

import UIKit

class FilterCategoryCell: UICollectionViewCell {
    static let id = "FilterCategoryCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 20
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        if isSelected {
            backgroundColor = .systemOrange.withAlphaComponent(0.2)
            titleLabel.textColor = .systemOrange
        } else {
            backgroundColor = .systemGray6
            titleLabel.textColor = .black
        }
    }
}
