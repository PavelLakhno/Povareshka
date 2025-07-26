//
//  RatingView.swift
//  Povareshka
//
//  Created by user on 22.07.2025.
//

import UIKit

final class RatingView: UIView {
    private var stars: [UIButton] = []
    var didSelectRating: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...5 {
            let button = UIButton()
            button.tag = i
            button.tintColor = .systemOrange
            button.setImage(Resources.Images.Icons.starEmpty, for: .normal)
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            stars.append(button)
            stack.addArrangedSubview(button)
        }
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(with rating: Int) {
        for (index, star) in stars.enumerated() {
            let image = index < rating ?
            Resources.Images.Icons.starFilled :
            Resources.Images.Icons.starEmpty
            star.setImage(image, for: .normal)
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        configure(with: rating)
        didSelectRating?(rating)
    }
}

