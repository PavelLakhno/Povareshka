//
//  ReviewPhotoCell.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

final class ReviewPhotoCell: UICollectionViewCell {
    static let id = "ReviewPhotoCell"
    
    private let imageView = UIImageView(cornerRadius: Constants.cornerRadiusSmall,
                                        contentMode: .scaleAspectFill)
    
    private lazy var activityIndicator = UIActivityIndicatorView.createIndicator(
        style: .medium,
        centerIn: self
    )

    private let dataService = DataService.shared
    
    private var currentImagePath: String?
    
    private var imageTask: Task<Void, Never>?
    
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
        imageTask?.cancel()
        imageView.image = nil
        activityIndicator.stopAnimating()
    }

    // MARK: - Public Methods
    func configure(with imagePath: String) {
        currentImagePath = imagePath
        imageTask?.cancel()
        activityIndicator.startAnimating()
        
        imageTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let image = try await dataService.loadImage(from: imagePath, bucket: Bucket.reviews)
                
                guard !Task.isCancelled, self.currentImagePath == imagePath else { return }
                
                self.imageView.image = image
                self.activityIndicator.stopAnimating()
            } catch {
                
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


