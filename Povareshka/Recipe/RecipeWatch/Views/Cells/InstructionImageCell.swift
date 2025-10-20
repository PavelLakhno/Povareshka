//
//  InstructionImageCell.swift
//  Povareshka
//
//  Created by user on 11.06.2025.
//

import UIKit
import Kingfisher

final class InstructionImageCell: UITableViewCell {
    static let id = "InstructionImageCell"

    private lazy var stepImageView = UIImageView(cornerRadius: Constants.cornerRadiusSmall)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stepImageView.kf.cancelDownloadTask()
        stepImageView.image = AppImages.Icons.cameraMain
    }
    
    private func setupViews() {
        contentView.addSubview(stepImageView)
        stepImageView.contentMode = .scaleAspectFill
        stepImageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            stepImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stepImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingSmall),
            stepImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingSmall),
            stepImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stepImageView.heightAnchor.constraint(equalTo: stepImageView.widthAnchor, multiplier: 0.6)
        ])
    }
    
    func configure(with imagePath: String) {
        stepImageView.image = AppImages.Icons.cameraMain
        
        Task { [weak self] in
            do {
                let url = try await DataService.shared.getImageURL(for: imagePath, bucket: Bucket.recipes)
                
                guard !Task.isCancelled else { return }

                DispatchQueue.main.async {
                    self?.stepImageView.kf.setImage(
                        with: url,
                        placeholder: AppImages.Icons.cameraMain,
                        options: [
                            .transition(.fade(0.3)),
                            .scaleFactor(UIScreen.main.scale),
                            .cacheOriginalImage,
                            .targetCache(ImageCache.default)
                        ]
                    )
                }
            } catch {
                guard !Task.isCancelled else { return }
                
                print("❌ Ошибка получения URL: \(error)")
                DispatchQueue.main.async  {
                    self?.stepImageView.image = AppImages.Icons.cameraMain
                }
            }
        }
    }
}
