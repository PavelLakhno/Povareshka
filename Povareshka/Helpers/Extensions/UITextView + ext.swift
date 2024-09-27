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

extension UITextView: UITextViewDelegate {

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
                self.addPlaceholderLabel(placeholderText: newValue!)
//                self.addClearButton(hiddenStatus: false)
            }
            else {
                placeHolderLabel?.text = newValue
                placeHolderLabel?.sizeToFit()
//                self.addClearButton(hiddenStatus: true)
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
        self.delegate = self;
    }
    
    func addClearButton(hiddenStatus: Bool) {
        let clearButton = UIButton()
        clearButton.layer.cornerRadius = 15
        clearButton.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        clearButton.setTitle(nil, for: .normal)
        clearButton.tintColor = .lightGray
        clearButton.isHidden = false
        clearButton.tag = 200
        clearButton.frame = CGRect(
            x: bounds.maxX - 30 - 4,
            y: bounds.midY - 30 / 2,
            width: 30,
            height: 30
        )
        clearButton.addTarget(self, action: #selector(onClearClick), for: .touchUpInside)
        textContainerInset.right = 30 + 4
        
        self.addSubview(clearButton)
        self.delegate = self;
    }
    
    @objc private func onClearClick() {
        text = nil
        delegate?.textViewDidChange?(self)
    }

    //MARK:- UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        let placeHolderLabel = self.viewWithTag(100)
        let clearButton = self.viewWithTag(200)
        placeHolderLabel?.isHidden = !self.hasText
        clearButton?.isHidden = !self.hasText
    }
}
