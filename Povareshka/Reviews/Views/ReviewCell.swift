//
//  ReviewCell.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

class ReviewCell: UITableViewCell {
    static let id = "ReviewCell"
    
    private var currentPhotos: [String] = []
    
    private let userStack = UIStackView()
    private let avatarImageView = UIImageView()
    private let userNameLabel = UILabel()
    private let ratingView = UIStackView()
    private let dateLabel = UILabel()
    private let commentLabel = UILabel()
    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(rating: Rating, userProfile: UserProfile?, photos: [String]) {
        
        self.currentPhotos = photos
        // Настройка аватара
        if let avatarPath = userProfile?.avatarPath {
            // Загрузка аватара из Supabase Storage
            Task {
                do {
                    let data = try await SupabaseManager.shared.client
                        .storage
                        .from("avatars")
                        .download(path: avatarPath)
                    
                    DispatchQueue.main.async {
                        self.avatarImageView.image = UIImage(data: data)
                    }
                } catch {
                    print("Ошибка загрузки аватара: \(error)")
                    self.avatarImageView.image = UIImage(systemName: "person.circle")
                }
            }
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle")
        }
        
        // Настройка имени пользователя
        userNameLabel.text = userProfile?.username ?? "Аноним"
        
        // Настройка рейтинга
        ratingView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for i in 1...5 {
            let star = UIImageView(image: UIImage(systemName: i <= rating.rating ? "star.fill" : "star"))
            star.tintColor = .systemOrange
            star.contentMode = .scaleAspectFit
            star.widthAnchor.constraint(equalToConstant: 16).isActive = true
            ratingView.addArrangedSubview(star)
        }
        
        // Настройка даты
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: rating.createdAt)
        
        // Настройка комментария
        commentLabel.text = rating.comment
        commentLabel.isHidden = rating.comment?.isEmpty ?? true
        
        // Настройка фото
        photosCollectionView.reloadData()
        photosCollectionView.isHidden = photos.isEmpty
    }
    
    private func setupView() {
        selectionStyle = .none
        backgroundColor = .clear
        layer.cornerRadius = 20
        
        // Настройка стека пользователя
        userStack.axis = .horizontal
        userStack.spacing = 8
        userStack.alignment = .center
        
        // Настройка аватара
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Настройка имени пользователя
        userNameLabel.font = .boldSystemFont(ofSize: 16)
        
        // Настройка стека рейтинга
        ratingView.axis = .horizontal
        ratingView.spacing = 2
        
        // Настройка даты
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        
        // Настройка комментария
        commentLabel.numberOfLines = 0
        commentLabel.font = .systemFont(ofSize: 14)
        
        // Настройка коллекции фото
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.register(ReviewPhotoCell.self, forCellWithReuseIdentifier: ReviewPhotoCell.id)
        photosCollectionView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Добавление на view
        let ratingDateStack = UIStackView(arrangedSubviews: [ratingView, dateLabel])
        ratingDateStack.spacing = 8
        ratingDateStack.alignment = .center
        
        userStack.addArrangedSubview(avatarImageView)
        userStack.addArrangedSubview(userNameLabel)
        
        let stack = UIStackView(arrangedSubviews: [userStack, ratingDateStack, commentLabel, photosCollectionView])
        stack.axis = .vertical
        stack.spacing = 8
        contentView.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}

extension ReviewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewPhotoCell.id, for: indexPath) as! ReviewPhotoCell
        cell.configure(with: currentPhotos[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Показ фото в полный размер
    }
}
