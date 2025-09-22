//
//  UIView + ext.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 27.08.2024.
//

import UIKit

extension UIView {
    func addBottomBorder(with color: UIColor, height: CGFloat) {
        let separator = UIView()
        separator.backgroundColor = color
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: height)
        ])
    }
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews where subview is UITextField || subview is UITextView {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
}

extension UIView {
    convenience init(size: CGSize? = nil,
                     backgroundColor: UIColor,
                     cornerRadius: CGFloat = 0) {
        self.init()
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.cornerCurve = .continuous
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let size = size {
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: size.width),
                self.heightAnchor.constraint(equalToConstant: size.height)
            ])
        }
    }
}

extension UIImageView {
    convenience init(image: UIImage? = Resources.Images.Icons.cameraMain,
                     size: CGSize? = nil,
                     cornerRadius: CGFloat = 0,
                     contentMode: ContentMode = .scaleAspectFill,
                     borderWidth: CGFloat = 0,
                     tintColor: UIColor = Resources.Colors.orange,
                     borderColor: UIColor = Resources.Colors.orange,
                     backgroundColor: UIColor = .white) {
        self.init()
        self.backgroundColor = backgroundColor
        self.contentMode = contentMode
        self.tintColor = tintColor
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        if let image = image {
            self.image = image
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Если задан size, устанавливаем констрейнты
        if let size = size {
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: size.width),
                self.heightAnchor.constraint(equalToConstant: size.height)
            ])
        }
    }
}

extension UIImage {
    func imageResized(to size: CGSize, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            if contentMode == .scaleAspectFit {
                let scale = min(size.width / size.width, size.height / size.height)
                let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
                let origin = CGPoint(x: (size.width - scaledSize.width) / 2, y: (size.height - scaledSize.height) / 2)
                draw(in: CGRect(origin: origin, size: scaledSize))
            } else {
                draw(in: rect)
            }
        }
    }
}

extension UILabel {
    convenience init(text: String = "", font: UIFont? = .helveticalBold(withSize: 20),backgroundColor: UIColor = .clear, textColor: UIColor = .gray, textAlignment: NSTextAlignment = .left, numberOfLines: Int = 0, height: CGFloat? = nil, layer: Bool? = nil) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.backgroundColor = backgroundColor
        self.numberOfLines = numberOfLines

//        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let layer = layer {
            self.layer.borderColor = Resources.Colors.orange.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = Constants.cornerRadiusSmall
            self.layer.masksToBounds = layer
        }
    }

    func addLeftPadding(_ padding: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = padding

        guard let text = self.text else { return }
        let attributedString = NSAttributedString(string: text, attributes: [
            .paragraphStyle: paragraphStyle
        ])

        self.attributedText = attributedString
    }
 
}

extension UITextField {
    func setPadding(_ amount: CGFloat, for side: UIRectEdge) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: bounds.height))
        if side.contains(.left) {
            leftView = paddingView
            leftViewMode = .always
        }
        if side.contains(.right) {
            rightView = paddingView
            rightViewMode = .always
        }
    }
}

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis,
                     alignment: UIStackView.Alignment,
                     distribution: UIStackView.Distribution = .fill,
                     spacing: CGFloat) {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}



extension UICollectionView {
    func dynamicHeightForCollectionView() {
//        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
        self.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = self.contentSize.height }
    }
}

extension UITableView {
    func dynamicHeightForTableView() {
//        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
        self.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = self.contentSize.height }
    }
    
    // notes
    func scrollToCenterOf(view: UIView) {
        guard let scrollView = view.superview as? UIScrollView else { return }

        // Получаем глобальные координаты выбранного представления
        let viewFrameInScrollView = view.convert(view.bounds, to: scrollView)
        
        // Находим центр этого представления
        let targetCenterY = viewFrameInScrollView.midY
        
        // Вычисляем центр экрана относительно scrollView
        let scrollViewCenterY = scrollView.frame.height / 2
        
        // Вычисляем новое смещение, чтобы выбранный UIView оказался в центре экрана
        var newContentOffset = scrollView.contentOffset
        newContentOffset.y = targetCenterY - scrollViewCenterY
        
        // Убедимся, что не выходим за пределы scrollView
        newContentOffset.y = max(0, min(newContentOffset.y, scrollView.contentSize.height - scrollView.bounds.height))
        
        // Анимированно прокручиваем к новому смещению
        scrollView.setContentOffset(newContentOffset, animated: true)
    }
}

extension UIButton {
    convenience init(
        title: String? = nil,
        image: UIImage? = nil,
        backgroundColor: UIColor = .clear,
        tintColor: UIColor = .white,
        titleColor: UIColor = .white,
        font: UIFont? = .helveticalRegular(withSize: 16),
        cornerRadius: CGFloat = 0,
        size: CGSize? = nil,
        target: Any?,
        action: Selector
    ) {
        self.init()
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor // Устанавливаем tintColor для кнопки

        if let title = title {
            self.setTitle(title, for: .normal)
            self.setTitleColor(titleColor, for: .normal)
            self.titleLabel?.font = font
        }

        if let image = image {
            // Используем renderingMode: .alwaysTemplate, чтобы tintColor работал динамически
            let templateImage = image.withRenderingMode(.alwaysTemplate)
            self.setImage(templateImage, for: .normal)
        }

        if let target = target {
            self.addTarget(target, action: action, for: .touchUpInside)
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        // Если задан size, устанавливаем констрейнты
        if let size = size {
            NSLayoutConstraint.activate([
                self.widthAnchor.constraint(equalToConstant: size.width),
                self.heightAnchor.constraint(equalToConstant: size.height)
            ])
        }
    }
}

extension UITextField {
    static func configureTextField(placeholder: String,
                                   delegate: UITextFieldDelegate? = nil,
                                   keyboardType: UIKeyboardType = .default,
                                   isSecureTextEntry: Bool = false,
                                   borderColor: UIColor = Resources.Colors.orange,
                                   cornerRadius: CGFloat = Constants.cornerRadiusSmall,
                                   backgroundColor: UIColor = .white,
                                   fontSize: CGFloat = 16) -> UITextField {
        let textField = UITextField()
        textField.layer.cornerRadius = cornerRadius
        textField.layer.borderColor = borderColor.cgColor
        textField.layer.borderWidth = 1
        textField.keyboardType = keyboardType
        textField.textAlignment = .left
        textField.returnKeyType = .done
        textField.setPadding(15, for: .left)
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = backgroundColor
        textField.isSecureTextEntry = isSecureTextEntry
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = delegate
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: fontSize)]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes as [NSAttributedString.Key : Any])
        return textField
    }
}

extension UIImagePickerController {
    convenience init(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate, sourceType: SourceType = .photoLibrary, allowsEditing: Bool = true) {
        self.init()
        self.delegate = delegate
        self.sourceType = sourceType
        self.allowsEditing = allowsEditing
    }
}

extension UIActivityIndicatorView {
    static func createIndicator(
        style: UIActivityIndicatorView.Style,
        color: UIColor = .gray,
        centerIn view: UIView? = nil) -> UIActivityIndicatorView {
            let indicator = UIActivityIndicatorView(style: style)
            indicator.color = color
            indicator.hidesWhenStopped = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
            
            if let view = view {
                view.addSubview(indicator)
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }
            
            return indicator
        }
}
