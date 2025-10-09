//
//  PhotoCell.swift
//  Povareshka
//
//  Created by user on 31.07.2025.
//

import UIKit
import Kingfisher

final class PhotoCell: UICollectionViewCell {
    static let id = "PhotoCell"
    
    private let imageView = UIImageView(cornerRadius: Constants.cornerRadiusSmall)
    private lazy var deleteButton = UIButton(image: AppImages.Icons.deleteFill,
                                             backgroundColor: .white,
                                             tintColor: .systemRed,
                                             cornerRadius: Constants.cornerRadiusSmall,
                                             size: Constants.iconCellSizeSmall,
                                             target: self,
                                             action: #selector(deleteTapped))
    var deleteHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.paddingSmall),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.paddingSmall),
        ])
    }
    
    @objc private func deleteTapped() {
        deleteHandler?()
    }
    
    func configure(with image: UIImage, showDelete: Bool = true) {
        imageView.image = image
        deleteButton.isHidden = !showDelete
    }
    
    func configure(with url: URL, showDelete: Bool = true) {
        imageView.kf.setImage(
            with: url,
            placeholder: AppImages.Icons.cameraMain,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
        deleteButton.isHidden = !showDelete
    }
}
