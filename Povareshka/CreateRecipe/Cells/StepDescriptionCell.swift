//
//  StepDescriptionCell.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 26.09.2024.
//

import UIKit


class StepDescriptionCell: UITableViewCell {
    
    static let id = "stepDescription"
    
    var textInput: String? = nil {
        didSet {
            stepDescribeTextView.text = textInput
            stepDescribeTextView.placeholder = textInput == nil ? "Введите описание" : nil
        }
    }
    
    lazy var stepDescribeTextView : UITextView = {
        let field = UITextView()
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.orange.cgColor
        field.layer.borderWidth = 1
        field.textAlignment = .left
        field.text = textInput
        field.returnKeyType = .done
        field.isScrollEnabled = false
        field.font = .helveticalRegular(withSize: 16)
        field.leftSpace(10)
        field.placeholder = "Введите описание"
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        stepDescribeTextView.text = nil
        stepDescribeTextView.placeholder = nil
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .neutral10
        contentView.addSubview(stepDescribeTextView)
        
        NSLayoutConstraint.activate([
            stepDescribeTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            stepDescribeTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepDescribeTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stepDescribeTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            stepDescribeTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }
}
