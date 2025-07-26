//
//  ReviewPhotoCell.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

class ReviewPhotoCell: UICollectionViewCell {
    static let id = "ReviewPhotoCell"
    
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(with imagePath: String) {
        // Загрузка изображения (можно использовать SDWebImage или аналоги)
        activityIndicator.startAnimating()
        Task {
            do {
                let data = try await SupabaseManager.shared.client
                    .storage
                    .from("reviews") //
                    .download(path: imagePath)
                
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                print("Ошибка загрузки фото: \(error)")
            }
        }
    }
    
    private func setupView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemOrange
        addSubview(imageView)
        addSubview(activityIndicator)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
