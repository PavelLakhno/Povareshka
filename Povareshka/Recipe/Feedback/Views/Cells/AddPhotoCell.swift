//
//  AddPhotoCell.swift
//  Povareshka
//
//  Created by user on 25.07.2025.
//

import UIKit

final class AddPhotoCell: UICollectionViewCell {
    static let id = "AddPhotoCell"
    
    private let iconView = UIImageView(image: Resources.Images.Icons.addFill,
                                       size: Constants.iconCellSizeMedium,
                                       contentMode: .scaleAspectFit,
                                       tintColor: .systemGray,
                                       backgroundColor: .clear)
    private let titleLabel = UILabel(text: Resources.Strings.Buttons.add,
                                     font: .helveticalRegular(withSize: 12),
                                     textColor: .black,
                                     textAlignment: .center)
    private let stackView = UIStackView(axis: .vertical,
                                        alignment: .center,
                                        spacing: Constants.spacingSmall)
    var addHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGesture()
    }
    
    private func setupViews() {
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        contentView.addSubview(stackView)
        backgroundColor = Resources.Colors.backgroundLight
        layer.cornerRadius = Constants.cornerRadiusSmall
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
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
