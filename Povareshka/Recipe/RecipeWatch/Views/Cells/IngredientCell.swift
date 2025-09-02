//
//  IngredientCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

final class IngredientCell: UITableViewCell {
    static let id = "IngredientCell"
    
    // MARK: - UI Elements
    private let titleLabel = UILabel(font: .helveticalRegular(withSize: 16),
                                     textColor: Resources.Colors.titleGray,
                                     textAlignment: .left)
    
    private lazy var addButton = UIButton(image: Resources.Images.Icons.addFill,
                                          tintColor: Resources.Colors.orange,
                                          size: Constants.iconCellSizeMedium,
                                          target: self,
                                          action: #selector(addButtonTapped))
    
    // MARK: - Properties
    private var ingredient: IngredientData?
    var addActionHandler: ((IngredientData) -> Void)?
    
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
        tintColor = Resources.Colors.orange

        contentView.addSubview(titleLabel)
        contentView.addSubview(addButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: addButton.leadingAnchor),
            
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
        ])
    }
    
    @objc private func addButtonTapped() {
        guard let ingredient = ingredient else { return }
        addActionHandler?(ingredient)
        addButton.setImage(Resources.Images.Icons.okFill, for: .normal)
        addButton.isEnabled = false
        
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
    
    // MARK: - Public Methods
    func configure(with ingredient: IngredientData, isAdded: Bool = false) {
        self.ingredient = ingredient
        titleLabel.text = "\(ingredient.name)  \(ingredient.amount)"
        
        let image = isAdded ? Resources.Images.Icons.okFill : Resources.Images.Icons.addFill
        addButton.setImage(image, for: .normal)
        addButton.isEnabled = !isAdded
    }
}

