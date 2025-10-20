//
//  ReviewPhotoCell.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit
import Kingfisher

final class ReviewPhotoCell: UICollectionViewCell {
    static let id = "ReviewPhotoCell"
    
    private let imageView = UIImageView(cornerRadius: Constants.cornerRadiusSmall,
                                        contentMode: .scaleAspectFill)
    
    private lazy var activityIndicator = UIActivityIndicatorView.createIndicator(
        style: .medium,
        centerIn: self
    )
    
    private var currentImagePath: String?
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        activityIndicator.stopAnimating()
        currentImagePath = nil
    }

    // MARK: - Public Methods
    func configure(with imagePath: String) {
        currentImagePath = imagePath
        imageView.kf.cancelDownloadTask()
        activityIndicator.startAnimating()

        Task { [weak self] in
            do {
                let url = try await DataService.shared.getImageURL(for: imagePath, bucket: Bucket.reviews)
                
                guard !Task.isCancelled else { return }
                guard self?.currentImagePath == imagePath else { return }

                DispatchQueue.main.async {
                    self?.imageView.kf.setImage(
                        with: url,
                        placeholder: AppImages.Icons.cameraMain,
                        options: [
                            .transition(.fade(0.3)),
                            .scaleFactor(UIScreen.main.scale),
                            .cacheOriginalImage,
                            .targetCache(ImageCache.default)
                        ]
                    )
                    self?.activityIndicator.stopAnimating()
                }
            } catch {
                guard !Task.isCancelled else { return }
                guard self?.currentImagePath == imagePath else { return }
                print("❌ Ошибка получения URL: \(error)")
                DispatchQueue.main.async  {
                    self?.imageView.image = AppImages.Icons.cameraMain
                }
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func setupView() {
        addSubview(imageView)
        addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}


