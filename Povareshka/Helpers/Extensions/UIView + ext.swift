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
        separator.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        separator.frame = CGRect(
            x: 0,
            y: frame.height - height,
            width: frame.width,
            height: height
        )
        
        addSubview(separator)
    }
}

extension UIView {
    convenience init(withBackgroundColor backgroundColor: UIColor, cornerRadius: CGFloat) {
        self.init()
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.cornerCurve = .continuous
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
    
    func setupView(_ view: UIView) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = bounds
        borderLayer.path = path.cgPath
        borderLayer.strokeColor = Resources.Colors.separator.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 1
        
        layer.mask = maskLayer
        layer.addSublayer(borderLayer)
        
    }
}

extension UITableView {
    func dynamicTextViewHeight() {

        let fixedWidth = self.frame.size.width
        let newHeight = self.sizeThatFits(CGSize(width: fixedWidth,
                                                     height: CGFloat.greatestFiniteMagnitude)).height
        self.translatesAutoresizingMaskIntoConstraints = true
        var newFrame = self.frame
        newFrame.size = CGSize(width: fixedWidth, height: newHeight)
        self.frame = newFrame
    }
}

extension UIView {
    func dynamicViewHeight() {

        let fixedWidth = self.frame.size.width
        let newHeight = self.sizeThatFits(CGSize(width: fixedWidth,
                                                     height: CGFloat.greatestFiniteMagnitude)).height

        print(newHeight)
        self.translatesAutoresizingMaskIntoConstraints = true
        var newFrame = self.frame
        newFrame.size = CGSize(width: fixedWidth, height: newHeight)
        self.frame = newFrame
    }
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
}

extension UIImageView {
    convenience init(image: UIImage?, cornerRadius: CGFloat, contentMode: ContentMode = .scaleToFill, borderWidth: CGFloat = 0  ) {
        self.init()
        self.contentMode = contentMode
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.orange.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        if let image = image {
            self.image = image
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension UILabel {
    
    convenience init(text: String = "", font: UIFont?, textColor: UIColor, textAligment: NSTextAlignment? = .center, numberOfLines: Int) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.adjustsFontSizeToFitWidth = true
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    static func configureTitleLabel(text: String, fontSize: CGFloat = 20, height: CGFloat = 28) -> UILabel {
        let label = UILabel()
        label.heightAnchor.constraint(equalToConstant: height).isActive = true
        label.font = .helveticalBold(withSize: fontSize)
        label.textColor = .gray
        label.textAlignment = .left
        label.text = text
        return label
    }

    func addLeftPadding(padding: CGFloat) {
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

    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, aligment: UIStackView.Alignment, spacing: CGFloat) {
        self.init()
        self.axis = axis
//        self.distribution = .fill
        self.alignment = aligment
        self.spacing = spacing
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UICollectionView {
    convenience init(itemWidth: Int, itemHeight: Int, delegate: UICollectionViewDelegate? = nil, dataSource: UICollectionViewDataSource? = nil ) {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flow.scrollDirection = .horizontal
        flow.sectionInset.right = 15
        flow.sectionInset.left = 15
        self.init(frame: .zero, collectionViewLayout: flow)
        self.showsHorizontalScrollIndicator = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        self.dataSource = dataSource
    }
}

extension UITableView {
    func dynamicHeightForTableView() {
        self.invalidateIntrinsicContentSize()
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

extension UITableView {
    func configure(cellClass: AnyClass, cellIdentifier: String, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.backgroundColor = .neutral10
        self.isScrollEnabled = false
        self.separatorStyle = .none
        self.sectionHeaderTopPadding = 0
        self.delegate = delegate
        self.dataSource = dataSource
//        self.dynamicHeightForTableView()

        self.register(cellClass, forCellReuseIdentifier: cellIdentifier)
    }
}

extension UIButton {
    convenience init(title: String? = nil,
                     image: UIImage? = nil,
                     backgroundColor: UIColor = .white,
                     tintColor: UIColor,
                     cornerRadius: CGFloat,
                     size: CGSize,
                     target: Any?,
                     action: Selector) {
        self.init()
        self.layer.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        if let title = title {
            self.setTitle(title, for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = .helveticalRegular(withSize: 20)
        }
        if let image = image {
            let resizedImage = image.imageResized(to: size)
            let tintedImage = resizedImage.withTintColor(tintColor, renderingMode: .alwaysOriginal)
            self.setImage(tintedImage, for: .normal)
        }
        if let target = target {
            self.addTarget(target, action: action, for: .touchUpInside)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UITextField {
    static func configureTextField(placeholder: String, delegate: UITextFieldDelegate? = nil) -> UITextField {
        let textField = UITextField()
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.orange.cgColor
        textField.layer.borderWidth = 1
        textField.textAlignment = .left
        textField.returnKeyType = .done
        textField.setLeftPaddingPoints(15)
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = delegate

        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes as [NSAttributedString.Key : Any])
        return textField
    }
}

extension UITextView {
    static func configureTextView(placeholder: String,
                                   delegate: UITextViewDelegate? = nil ) -> UITextView {
        let textView = UITextView()
        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.orange.cgColor
        textView.layer.borderWidth = 1
        textView.textAlignment = .left
        textView.textColor = .lightGray
        textView.returnKeyType = .done
        textView.isScrollEnabled = false
        textView.leftSpace(10)
        textView.font = .helveticalRegular(withSize: 16)
        textView.placeholder = placeholder
        textView.delegate = delegate //
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }
}
extension UIImagePickerController {
    convenience init(delegate: UIImagePickerControllerDelegate &
                     UINavigationControllerDelegate) {
        self.init()
        self.delegate = delegate
        self.sourceType = .photoLibrary
        self.allowsEditing = true
    }
}

extension UIPickerView {
    func configure(dataSource: UIPickerViewDataSource, delegate: UIPickerViewDelegate) {
        self.dataSource = dataSource
        self.delegate = delegate
    }
}

extension UIView {
    convenience init(backgroundColor: UIColor, cornerRadius: CGFloat = 0) {
        self.init()
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
