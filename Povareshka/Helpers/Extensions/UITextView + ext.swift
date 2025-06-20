//
//  UITextView + ext.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 18.09.2024.
//

import UIKit

extension UITextView {
    func leftSpace(_ amount:CGFloat) {
        self.textContainerInset = UIEdgeInsets(top: 4, left: amount, bottom: 4, right: 4)
    }
}

//extension UITextView: @retroactive UIScrollViewDelegate {}
extension UITextView: @retroactive UITextViewDelegate {

    var placeholder: String? {

        get {
            var placeholderText: String?

            if let placeHolderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeHolderLabel.text
            }
            return placeholderText
        }

        set {
            let placeHolderLabel = self.viewWithTag(100) as! UILabel?
            if placeHolderLabel == nil {
                self.addPlaceholderLabel(placeholderText: newValue ?? "")
            }
            else {
                placeHolderLabel?.text = newValue
                placeHolderLabel?.sizeToFit()
            }
        }
    }
    
    var clearButtonStatus: Bool {
        get {
            var isHidden: Bool

            if let button = self.viewWithTag(200) as? UIButton {
                isHidden = button.isHidden
            } else {
                isHidden = true
            }
            return isHidden
        }

        set {
            let button = self.viewWithTag(200) as! UIButton?
            if button == nil {
                self.addClearButton(isHidden: newValue)
            } else {
                button?.isHidden = newValue
            }
        }

    }

    
    private func addPlaceholderLabel(placeholderText: String) {

        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin.x = 15.0
        placeholderLabel.frame.origin.y = 5.0
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        self.addSubview(placeholderLabel)
    }
    
    
    private func addClearButton(isHidden: Bool) {
        
        let button = UIButton()
        button.layer.cornerRadius = 15
        button.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        button.setTitle(nil, for: .normal)
        button.tintColor = .lightGray.withAlphaComponent(0.5)
        button.frame = CGRect(
            x: bounds.maxX - 30 ,
            y: bounds.minY,
            width: 30,
            height: 30)
        button.tag = 200
        button.addTarget(self, action: #selector(onClearClick), for: .touchUpInside)
        button.isHidden = isHidden
        
        self.addSubview(button)
    }

    @objc private func onClearClick() {
        text = nil
        delegate?.textViewDidChange?(self)
    }
    
    public func setConstraints() {
        let placeholderLabel = self.viewWithTag(100) as! UILabel
        let clearButton = self.viewWithTag(200) as! UIButton
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            
            clearButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            clearButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30)
        ])
    }
    
    func dynamicTextViewHeight(_ constHeight: CGFloat) {

        let fixedWidth = self.frame.size.width
        let newHeight = self.sizeThatFits(CGSize(width: fixedWidth,
                                                     height: CGFloat.greatestFiniteMagnitude)).height
        self.translatesAutoresizingMaskIntoConstraints = true
        var newFrame = self.frame
        
        if constHeight < newHeight {
            newFrame.size = CGSize(width: fixedWidth, height: newHeight)
        } else {
            newFrame.size = CGSize(width: fixedWidth, height: constHeight)
        }
        self.frame = newFrame
    }

}
extension UITextView {
    func dynamicTextViewHeight(minHeight: CGFloat) {
        guard minHeight > 0 else { return }
        
        let fixedWidth = self.frame.size.width
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth,
                                              height: CGFloat.greatestFiniteMagnitude))
        
        // Находим height constraint (если есть)
        let heightConstraint = self.constraints.first { $0.firstAttribute == .height }
        
        // Устанавливаем новую высоту (не меньше minHeight)
        let newHeight = max(newSize.height, minHeight)
        
        // Обновляем constraint или frame
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = newHeight
        } else {
            self.frame.size.height = newHeight
        }
        
        self.layoutIfNeeded()
    }
}

