//
//  ReviewCell.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit
import Kingfisher

final class ReviewCell: UITableViewCell {
    static let id = "ReviewCell"
    
    private let dataService = DataService.shared
    
    // MARK: - UI Elements
    private let avatarImageView = UIImageView(image: AppImages.Icons.avatar,
                                              size: Constants.iconCellSizeBig,
                                              cornerRadius: Constants.cornerRadiusBig,
                                              contentMode: .scaleAspectFill)
    private let userNameLabel = UILabel(font: .helveticalBold(withSize: 16),
                                       textColor: .black,
                                       textAlignment: .left)
    private let ratingView = RatingView()
    private let dateLabel = UILabel(font: .helveticalRegular(withSize: 12),
                                    textColor: .black,
                                   textAlignment: .left)
    private let commentLabel = UILabel(font: .helveticalRegular(withSize: 14),
                                      textColor: .black,
                                      textAlignment: .left,
                                      numberOfLines: 0)
    
    private let userStack = UIStackView(axis: .horizontal, alignment: .center, spacing: Constants.spacingSmall)
    private let ratingStack = UIStackView(axis: .horizontal, alignment: .center, spacing: Constants.spacingSmall)
    private var mainStack: UIStackView!
        
    private lazy var photosCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(Constants.photoCellSizeMedium),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: ReviewPhotoCell.self, identifier: ReviewPhotoCell.id)
            ],
            delegate: self,
            dataSource: self
        )
        return collectionView
    }()
    
    // MARK: - Properties
    private var currentPhotos: [String] = []
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
        currentPhotos = []
    }
    
    // MARK: - Public Methods
    func configure(with rating: Rating, userProfile: UserProfileShort?, photos: [String]) {
        configureUserInfo(userProfile)
        configureRating(rating)
        configureComment(rating.comment)
        configurePhotos(photos)
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        layer.cornerRadius = Constants.cornerRadiusMedium
        
        userStack.addArrangedSubview(avatarImageView)
        userStack.addArrangedSubview(userNameLabel)

        ratingStack.addArrangedSubview(ratingView)
        ratingStack.addArrangedSubview(dateLabel)
        
        mainStack = UIStackView(arrangedSubviews: [userStack, ratingStack, commentLabel, photosCollectionView])
        mainStack.axis = .vertical
        mainStack.spacing = Constants.spacingMedium
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)

    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photosCollectionView.heightAnchor.constraint(equalToConstant: 80),
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.spacingMedium),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.spacingMedium),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.spacingMedium),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.spacingMedium)
        ])
    }

    private func configureUserInfo(_ userProfile: UserProfileShort?) {
        userNameLabel.text = userProfile?.username ?? AppStrings.Titles.anonymous

        avatarImageView.image = AppImages.Icons.avatar
        guard let avatarPath = userProfile?.avatarPath else { return }

        Task { [weak self] in
            do {
                let url = try await DataService.shared.getImageURL(for: avatarPath, bucket: Bucket.avatars)
                
                guard !Task.isCancelled else { return }

                DispatchQueue.main.async {
                    self?.avatarImageView.kf.setImage(
                        with: url,
                        placeholder: AppImages.Icons.avatar,
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
                    self?.avatarImageView.image = AppImages.Icons.avatar
                }
            }
        }
    }
    
    private func configureRating(_ rating: Rating) {
        ratingView.configure(with: rating.rating)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: rating.createdAt)
    }
    
    private func configureComment(_ comment: String?) {
        commentLabel.text = comment
        commentLabel.isHidden = comment?.isEmpty ?? true
    }
    
    private func configurePhotos(_ photos: [String]?) {
        currentPhotos = photos ?? []
        photosCollectionView.reloadData()
        photosCollectionView.isHidden = currentPhotos.isEmpty
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ReviewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ReviewPhotoCell.id,
            for: indexPath
        ) as? ReviewPhotoCell else {
            return ReviewPhotoCell()
        }
        
        cell.configure(with: currentPhotos[indexPath.item])
        return cell
    }
}
