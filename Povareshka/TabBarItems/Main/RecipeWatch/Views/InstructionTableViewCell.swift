//
//  InstructionTableViewCell.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit
//
//class InstructionTableViewCell: UITableViewCell {
//    
//    static let id = "InstructionCell"
//    
//    private var instructionImageTask: Task<Void, Never>?
//    
//    private let stepLabel: UILabel = {
//        let label = UILabel()
//        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    private let descriptionLabel = UILabel()
//    private let stepImageView = UIImageView()
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        stepLabel.translatesAutoresizingMaskIntoConstraints = false
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        stepImageView.translatesAutoresizingMaskIntoConstraints = false
//        stepImageView.contentMode = .scaleToFill
//        
//        contentView.addSubview(stepLabel)
//        contentView.addSubview(descriptionLabel)
//        contentView.addSubview(stepImageView)
//        
//        NSLayoutConstraint.activate([
//            stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            
//            descriptionLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 8),
//            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//
//            stepImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
//            stepImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            stepImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            stepImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.65),
//            stepImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            stepImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
//        ])
//    }
// 
//    func configure(with instruction: InstructionSupabase) {
//        stepLabel.text = "Шаг \(instruction.stepNumber)"
//        stepLabel.font = .helveticalBold(withSize: 18)
//        descriptionLabel.text = instruction.description
//        descriptionLabel.numberOfLines = 0
//        loadInstructionImage(path: instruction.imagePath)
//    }
//   
//    private func loadInstructionImage(path: String?) {
//        guard let path = path else {
//            stepImageView.image = UIImage(named: "recipe_placeholder")
//            return
//        }
//        
//        // Проверяем кэш
//        if let cachedImage = ImageCache.shared.image(for: path) {
//            stepImageView.image = cachedImage
//            return
//        }
//        instructionImageTask?.cancel()
//        instructionImageTask = Task {
//            do {
//                let data = try await SupabaseManager.shared.client
//                    .storage
//                    .from("recipes")
//                    .download(path: path)
//                
//                if !Task.isCancelled, let image = UIImage(data: data) {
//                    ImageCache.shared.setImage(image, for: path)
//                    stepImageView.image = image
//                }
//            } catch {
//                if !Task.isCancelled {
//                    stepImageView.image = UIImage(named: "placeholder")
//                }
//            }
//        }
//    }
//
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        instructionImageTask?.cancel()
//        stepImageView.image = nil
//    }
//}

class InstructionTableViewCell: UITableViewCell {
    
    static let id = "InstructionCell"
    
    private var instructionImageTask: Task<Void, Never>?
    private var imageBottomConstraint: NSLayoutConstraint!
    
    // UI Elements
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticalBold(withSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stepImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        instructionImageTask?.cancel()
        stepImageView.image = nil
        stepImageView.isHidden = true
        imageBottomConstraint.constant = -12 // Стандартный отступ без изображения
    }
    
    // MARK: - Configuration
    func configure(with instruction: InstructionSupabase) {
        stepLabel.text = "Шаг \(instruction.stepNumber)"
        descriptionLabel.text = instruction.description
        
        if let imagePath = instruction.imagePath {
            loadImage(path: imagePath)
        } else {
            stepImageView.isHidden = true
            imageBottomConstraint.constant = -12 // Отступ без изображения
        }
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        contentView.addSubview(stepLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(stepImageView)
        
        // Основные констрейнты
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stepLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stepLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            stepImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            stepImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stepImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stepImageView.heightAnchor.constraint(equalTo: stepImageView.widthAnchor, multiplier: 0.6)
        ])
        
        // Динамический констрейнт для нижнего отступа
        imageBottomConstraint = stepImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        imageBottomConstraint.isActive = true
        
        // Изначально скрываем изображение
        stepImageView.isHidden = true
    }
    
    private func loadImage(path: String) {
        instructionImageTask?.cancel()
        
        // Проверка кэша
        if let cachedImage = ImageCache.shared.image(for: path) {
            setImage(cachedImage)
            return
        }
        
        instructionImageTask = Task {
            do {
                let data = try await SupabaseManager.shared.client
                    .storage
                    .from("recipes")
                    .download(path: path)
                
                if !Task.isCancelled, let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: path)
                    setImage(image)
                }
            } catch {
                if !Task.isCancelled {
                    setImage(nil)
                }
            }
        }
    }
    
    private func setImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            if let image = image {
                self.stepImageView.image = image
                self.stepImageView.isHidden = false
                self.imageBottomConstraint.constant = -12 // Стандартный отступ
            } else {
                self.stepImageView.isHidden = true
                self.imageBottomConstraint.constant = -12 // Такой же отступ, но без изображения
            }
            self.layoutIfNeeded()
        }
    }
}
