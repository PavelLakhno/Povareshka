//
//  UITextView + ext.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 18.09.2024.
//

import UIKit

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
        button.setImage(Resources.Images.Icons.cancel, for: .normal)
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
    
    func dynamicTextViewHeight(minHeight: CGFloat) {

        let fixedWidth = self.frame.size.width
        let newHeight = self.sizeThatFits(CGSize(width: fixedWidth,
                                                     height: CGFloat.greatestFiniteMagnitude)).height
        self.translatesAutoresizingMaskIntoConstraints = true
        var newFrame = self.frame
        
        if minHeight < newHeight {
            newFrame.size = CGSize(width: fixedWidth, height: newHeight)
        } else {
            newFrame.size = CGSize(width: fixedWidth, height: minHeight)
        }
        self.frame = newFrame
    }

}

extension UITextView {
    static func configureTextView(placeholder: String,
                                  delegate: UITextViewDelegate? = nil,
                                  borderColor: UIColor = Resources.Colors.orange,
                                  cornerRadius: CGFloat = 8,
                                  fontSize: CGFloat = 16,
                                  isScroll: Bool = false,
                                  textContainerInset: UIEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 30)) -> UITextView {
        let textView = UITextView()
        textView.layer.cornerRadius = cornerRadius
        textView.layer.borderColor = borderColor.cgColor
        textView.layer.borderWidth = 1
        textView.textAlignment = .left
        textView.textColor = .lightGray
        textView.returnKeyType = .done
        textView.isScrollEnabled = isScroll
        textView.textContainerInset = textContainerInset
        textView.font = .helveticalRegular(withSize: fontSize)
        textView.placeholder = placeholder
        textView.delegate = delegate
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
}
