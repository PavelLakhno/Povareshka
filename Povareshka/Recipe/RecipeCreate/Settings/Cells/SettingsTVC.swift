//
//  SettingsTVC.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 09.11.2024.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    static let id = "SettingTableViewCell"

    private var indexPath: IndexPath?
    
    // MARK: - UI Elements
    private let bubbleView = UIView(
        backgroundColor: Resources.Colors.backgroundMedium,
        cornerRadius: Constants.cornerRadiusSmall
    )//
    
    private let iconBubleView = UIView(
        size: Constants.iconCellSizeBig,
        backgroundColor: Resources.Colors.background,
        cornerRadius: Constants.cornerRadiusSmall
    )
    
    private let iconImage = UIImageView(
        size: Constants.iconCellSizeMedium,
        contentMode: .scaleAspectFit,
        tintColor: Resources.Colors.orange,
        backgroundColor: .clear
    )

    private let titleLabel = UILabel(
        font: .helveticalRegular(withSize: 16),
        textColor: Resources.Colors.titleGray,
        textAlignment: .left, numberOfLines: 2
    )
    
    private let valueLabel = UILabel(
        font: .helveticalRegular(withSize: 16),
        textColor: Resources.Colors.secondary,
        textAlignment: .right
    )

    private lazy var actionButton = UIButton(
        image: Resources.Images.Icons.forward,
        tintColor: Resources.Colors.orange,
        size: Constants.iconCellSizeMedium,
        target: self,
        action: #selector(actionButtonTapped)
    )
    
    var actionHandler: ((IndexPath) -> Void)?
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = Resources.Colors.backgroundLight
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(iconBubleView)
        iconBubleView.addSubview(iconImage)
        bubbleView.addSubview(titleLabel)
        bubbleView.addSubview(valueLabel)
        bubbleView.addSubview(actionButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingSmall),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingSmall),
            bubbleView.heightAnchor.constraint(equalToConstant: 60),
            
            iconBubleView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            iconBubleView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Constants.paddingMedium),
            
            iconImage.centerXAnchor.constraint(equalTo: iconBubleView.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconBubleView.centerYAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconBubleView.trailingAnchor, constant: Constants.paddingMedium),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -Constants.paddingMedium),
            
            valueLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -Constants.paddingMedium),
            valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            actionButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Constants.paddingMedium),
        ])
    }
    
    // MARK: - Public Methods
    func configure(with title: String, iconName: UIImage, value: String?, indexPath: IndexPath) {
        self.indexPath = indexPath
        titleLabel.text = title
        iconImage.image = iconName
        valueLabel.text = value
    }
    
    // Сохранено из исходного кода
    func setValueText(_ text: String?) {
        valueLabel.text = text
    }

    func setActionButtonEnabled(_ isEnabled: Bool) {
        actionButton.isEnabled = isEnabled
    }
    
    @objc private func actionButtonTapped() {
        guard let indexPath = indexPath else { return }
        actionHandler?(indexPath)
    }
}
