//
//  PhotoViewerCell.swift
//  Povareshka
//
//  Created by user on 14.08.2025.
//

import UIKit
import Kingfisher

final class PhotoViewerCell: UICollectionViewCell  {
    static let id = "PhotoViewerCell"
    
    private let imageView = UIImageView(contentMode: .scaleAspectFit)
    private var currentImagePath: String?

    private lazy var activityIndicator = UIActivityIndicatorView.createIndicator(
        style: .medium,
        centerIn: contentView
    )
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.maximumZoomScale = 3.0
        sv.minimumZoomScale = 1.0
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
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
    }
   
    private func setupView() {
        addDoubleTapped()
        contentView.addSubview(activityIndicator)
        contentView.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])
    }
    
    // MARK: - Help Methods
    private func addDoubleTapped() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let point = recognizer.location(in: imageView)
            let zoomRect = CGRect(
                x: point.x - 40,
                y: point.y - 40,
                width: 80,
                height: 80
            )
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    // MARK: - Public Methods
    func configure(with imagePath: String) {
        currentImagePath = imagePath

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
                
                print("❌ Ошибка получения URL: \(error)")
                DispatchQueue.main.async  {
                    self?.imageView.image = AppImages.Icons.cameraMain
                    self?.activityIndicator.stopAnimating()
                }
                
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoViewerCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
