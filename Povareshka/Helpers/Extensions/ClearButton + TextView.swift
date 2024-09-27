//
//  ClearButton + TextView.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 17.09.2024.
//

import UIKit

final class ClearableTextView: UITextView {
    
    var isButtonHidden = true
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.tintColor = .systemGray
        button.isHidden = isButtonHidden
        addSubview(button)
        return button
    } ()
    
    let clearButtonSize: CGFloat = 30
    let clearButtonRightInset: CGFloat = 4
    
    
    override var bounds: CGRect {
        didSet {
            clearButton.frame = CGRect(
                x: bounds.maxX - clearButtonSize - clearButtonRightInset,
                y: bounds.midY - clearButtonSize / 2,
                width: clearButtonSize,
                height: clearButtonSize
            )
        }
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super .init(coder: coder)
        setup()
    }
    
    private func setup() {
        clearButton.addTarget(self, action: #selector(onClearClick1), for: .touchUpInside)
        textContainerInset.right = clearButtonSize + clearButtonRightInset
    }
    
    @objc private func onClearClick1() {
        text = nil
        delegate?.textViewDidChange?(self)
    }
}
