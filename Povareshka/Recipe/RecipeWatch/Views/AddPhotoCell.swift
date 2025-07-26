//
//  AddPhotoCell.swift
//  Povareshka
//
//  Created by user on 25.07.2025.
//

import UIKit

final class AddPhotoCell: UICollectionViewCell {
    static let id = "AddPhotoCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    var addHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGesture()
    }
    
    private func setupViews() {
        // Настройка иконки
        iconView.image = UIImage(systemName: "plus.circle.fill")
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        // Настройка текста
        titleLabel.text = "Добавить"
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .systemGray
        titleLabel.textAlignment = .center
        
        // Вертикальный стек
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        contentView.addSubview(stack)
        
        // Констрейнты
        stack.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
        
        // Стиль ячейки
        backgroundColor = .systemGray6
        layer.cornerRadius = 12
    }
    
    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tap)
        contentView.isUserInteractionEnabled = true
    }
    
    @objc private func cellTapped() {
        addHandler?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
