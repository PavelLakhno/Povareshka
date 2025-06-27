//
//  IngredientCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

class IngredientCell: UITableViewCell {
    
    static let id = "IngredientCell"
    
    // MARK: - UI Elements
    let addButton = UIButton()
        
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupButton()
        tintColor = Resources.Colors.orange
        selectionStyle = .none
        backgroundColor = .neutral10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        addButton.setImage(Resources.Images.Icons.addFill, for: .normal)
//        addButton.tintColor = Resources.Colors.orange
        addButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        accessoryView = addButton
    }
    
//    override func didTransition(to state: UITableViewCell.StateMask) {
//        super.didTransition(to: state)
        // Maintain button color during transitions
//        addButton.tintColor = .systemOrange
//    }
}
