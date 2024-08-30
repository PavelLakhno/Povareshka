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
}

extension UIImageView {
    convenience init(image: String, cornerRadius: CGFloat) {
        self.init()
        self.image = UIImage(named: image)
        self.contentMode = .scaleAspectFill
        self.layer.masksToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.translatesAutoresizingMaskIntoConstraints = false
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
}



extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis, aligment: UIStackView.Alignment, spacing: CGFloat) {
        self.init()
        self.axis = axis
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

