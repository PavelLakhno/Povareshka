//
//  InstructionImageCell.swift
//  Povareshka
//
//  Created by user on 11.06.2025.
//

import UIKit

final class InstructionImageCell: UITableViewCell {
    static let id = "InstructionImageCell"
    
    private var imageTask: Task<Void, Never>?
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
        imageTask?.cancel()
        stepImageView.image = nil
    }
    
    private func setupViews() {
        contentView.addSubview(stepImageView)
        
        NSLayoutConstraint.activate([
            stepImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stepImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingSmall),
            stepImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingSmall),
            stepImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stepImageView.heightAnchor.constraint(equalTo: stepImageView.widthAnchor, multiplier: 0.6)
        ])
    }
    
    func configure(with imagePath: String) {
        imageTask?.cancel()

        if let cachedImage = ImageCache.shared.image(for: imagePath) {
            stepImageView.image = cachedImage
            return
        }

        imageTask = Task {
            do {
                let image = try await DataService.shared.loadImage(from: imagePath, bucket: Bucket.recipes)
                if !Task.isCancelled {
                    stepImageView.image = image
                }
            } catch {
                print("Ошибка загрузки: \(error)")
            }
        }
    }
}
