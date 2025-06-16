//
//  InstructionImageCell.swift
//  Povareshka
//
//  Created by user on 11.06.2025.
//

import UIKit

class InstructionImageCell: UITableViewCell {
    static let id = "InstructionImageCell"
    
    private var imageTask: Task<Void, Never>?
    private let stepImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
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
            stepImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            stepImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stepImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stepImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            stepImageView.heightAnchor.constraint(equalTo: stepImageView.widthAnchor, multiplier: 0.6)
        ])
    }
    
    func configure(with imagePath: String) {
        loadImage(path: imagePath)
    }
    
    private func loadImage(path: String) {
        imageTask?.cancel()
        
        if let cachedImage = ImageCache.shared.image(for: path) {
            stepImageView.image = cachedImage
            return
        }
        
        imageTask = Task {
            do {
                let data = try await SupabaseManager.shared.client
                    .storage
                    .from("recipes")
                    .download(path: path)
                
                if !Task.isCancelled, let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: path)
                    stepImageView.image = image
                }
            } catch {
                if !Task.isCancelled {
                    stepImageView.image = UIImage(named: "recipe_placeholder")
                }
            }
        }
    }
}
