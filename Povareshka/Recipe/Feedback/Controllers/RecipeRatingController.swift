//
//  RecipeRatingController.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit

final class RecipeRatingController: BaseController {
    // MARK: - Properties
    private let recipeId: UUID
    private var currentRating: Int?
    private var comment: String?

    private let dataService = DataService.shared
    
    // Photo Management
    private var photos: [UIImage] = []           // Display photos
    private var serverPhotoPaths: [String] = []  // Server-stored photo paths
    private var photosToDelete: [String] = []    // Photos marked for deletion
    private var newPhotos: [UIImage] = []        // New photos to upload
    
    // UI Components
    private let customScrollView = UIScrollView(backgroundColor: .systemBackground)
    override var scrollView: UIScrollView { customScrollView }
    private let contentView = UIView(backgroundColor: .systemBackground)
    private let contentStackView = UIStackView(
        axis: .vertical,
        alignment: .fill,
        spacing: Constants.spacingBig
    )
    private let photosContainer = UIView(backgroundColor: .systemBackground)
    
    private let starsTitleLabel = UILabel(text: Resources.Strings.Titles.rating,
                                          font: .helveticalBold(withSize: 18),
                                          textColor: .black)
    private let starsView = RatingView()
    
    private let commentTitleLabel = UILabel(text: Resources.Strings.Titles.commentOptional,
                                            font: .helveticalBold(withSize: 18),
                                            textColor: .black)
    private lazy var commentTextView = UITextView.configureTextView(
        placeholder: Resources.Strings.Placeholders.enterText, delegate: self
    )
    
    private let photosTitleLabel = UILabel(text: Resources.Strings.Titles.photosOptional,
                                           font: .helveticalBold(withSize: 18),
                                           textColor: .black)
    private lazy var photosCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(Constants.categoryCellSize),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: AddPhotoCell.self, identifier: AddPhotoCell.id),
                CollectionViewCellConfig(cellClass: PhotoCell.self, identifier: PhotoCell.id)
            ],
            delegate: self,
            dataSource: self
        )
        return collectionView
    }()

    private lazy var loadingIndicator = UIActivityIndicatorView.createIndicator(
        style: .large,
        centerIn: photosContainer
    )
    
    private lazy var photoPickerView = UIImagePickerController(delegate: self)
    
    // MARK: - Initialization
    init(recipeId: UUID?) {
        self.recipeId = recipeId ?? UUID()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupNavigationBar()
        setupStarsView()
        loadCurrentRating()
        loadReviewPhotos()
    }
    
    // MARK: - Setup Methods

    private func setupNavigationBar() {
        navigationItem.title = Resources.Strings.Titles.rateRecipe
        addNavBarButtons(at: .left, types: [.title(Resources.Strings.Buttons.cancel)])
        addNavBarButtons(at: .right,
                         types: [.title(
                            currentRating == nil ?
                            Resources.Strings.Buttons.rate : Resources.Strings.Buttons.update)]
        )
    }

    private func setupStarsView() {
        starsView.didSelectRating = { [weak self] rating in
            self?.currentRating = rating
            self?.setupNavigationBar()
        }
    }
    
    // MARK: - Data Loading
    private func loadCurrentRating() {
        Task {
            do {
                let rating = try await dataService.fetchUserRating(recipeId: recipeId)
                DispatchQueue.main.async {
                    self.currentRating = rating?.rating
                    self.comment = rating?.comment
                    self.starsView.configure(with: rating?.rating ?? 0)
                    if let comment = rating?.comment, !comment.isEmpty {
                        self.commentTextView.text = comment
                        self.commentTextView.textColor = .black // Устанавливаем цвет основного текста
                        self.commentTextView.placeholder = nil // Убираем placeholder
                    } else {
                        self.commentTextView.text = nil
                        self.commentTextView.textColor = .lightGray
                        self.commentTextView.placeholder = Resources.Strings.Placeholders.enterText
                    }
                    self.setupNavigationBar()
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.shared.showError(on: self, error: error)
                }
            }
        }
    }
    
    private func loadReviewPhotos() {
        showPhotoLoadingState()
        
        Task {
            do {
                guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
                    throw RatingError.userNotAuthenticated
                }
                let photosInfo = try await dataService.getReviewPhotosInfo(recipeId: recipeId, userId: userId)
                self.serverPhotoPaths = photosInfo.map { $0.photoPath }
                self.photos = try await dataService.loadReviewPhotos(recipeId: recipeId, userId: userId)
                
                DispatchQueue.main.async {
                    self.hidePhotoLoadingState()
                    self.photosCollectionView.reloadData()
                    self.photosCollectionView.dynamicHeightForCollectionView()
                }
            } catch {
                DispatchQueue.main.async {
                    self.hidePhotoLoadingState()
                    AlertManager.shared.showError(on: self, error: error)
                }
            }
        }
    }
    
    // MARK: - Action Methods
    
    internal override func navBarLeftButtonHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    internal override func navBarRightButtonHandler() {
        guard let rating = currentRating else {
            AlertManager.shared.show(
                on: self,
                title: Resources.Strings.Alerts.errorTitle,
                message: Resources.Strings.Messages.failedSaveData
            )
            return
        }

        let comment = commentTextView.text.isEmpty ? nil : commentTextView.text
        
        Task {
            do {
                try await dataService.submitRating(
                    recipeId: recipeId,
                    rating: rating,
                    comment: comment
                )
                
                if !photosToDelete.isEmpty {
                    try await dataService.deletePhotos(paths: photosToDelete)
                }
                
                if !newPhotos.isEmpty {
                    let _ = try await dataService.uploadPhotos(recipeId: recipeId, photos: newPhotos)
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    AlertManager.shared.showError(on: self, error: error)
                }
            }
        }
    }

    
    @objc private func addPhotoTapped() {
        present(photoPickerView, animated: true)
    }
    
    // MARK: - Helper Methods
    private func deletePhoto(at index: Int) {
        if index < serverPhotoPaths.count {
            photosToDelete.append(serverPhotoPaths[index])
            serverPhotoPaths.remove(at: index)
        } else {
            let newPhotoIndex = index - serverPhotoPaths.count
            if newPhotos.indices.contains(newPhotoIndex) {
                newPhotos.remove(at: newPhotoIndex)
            }
        }
        
        photos.remove(at: index)
        photosCollectionView.reloadData()
        photosCollectionView.dynamicHeightForCollectionView()
    }
}

// MARK: - Keyboard Handling
extension RecipeRatingController {
    private func showPhotoLoadingState() {
        photosCollectionView.isHidden = true
        loadingIndicator.startAnimating()
    }
    
    private func hidePhotoLoadingState() {
        photosCollectionView.isHidden = false
        loadingIndicator.stopAnimating()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension RecipeRatingController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddPhotoCell.id, for: indexPath) as? AddPhotoCell else {
                return UICollectionViewCell()
            }
            cell.addHandler = { [weak self] in
                self?.addPhotoTapped()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath) as? PhotoCell else {
                return UICollectionViewCell()
            }
            let photoIndex = indexPath.item - 1
            cell.configure(with: photos[photoIndex])
            cell.deleteHandler = { [weak self] in
                self?.deletePhoto(at: photoIndex)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        Constants.categoryCellSize
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension RecipeRatingController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        
        photos.append(image)
        newPhotos.append(image)
        photosCollectionView.reloadData()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension RecipeRatingController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.clearButtonStatus = !textView.hasText
        textView.textColor = UIColor.black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        textView.clearButtonStatus = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.placeholder = textView.hasText ? nil : Resources.Strings.Placeholders.enterText
        textView.clearButtonStatus = !textView.hasText
    }
}

// MARK: - Constraints
extension RecipeRatingController {
    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = Resources.Colors.backgroundLight
        scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        
        photosContainer.addSubview(photosCollectionView)
        photosContainer.addSubview(loadingIndicator)
        
        contentStackView.addArrangedSubview(starsTitleLabel)
        contentStackView.addArrangedSubview(starsView)
        contentStackView.addArrangedSubview(commentTitleLabel)
        contentStackView.addArrangedSubview(commentTextView)
        contentStackView.addArrangedSubview(photosTitleLabel)
        contentStackView.addArrangedSubview(photosContainer)
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.spacingMedium),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.spacingMedium),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            // ContentStackView
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // CommentTextView
            commentTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.heightStandart),
            
            // Photos Container
            photosCollectionView.topAnchor.constraint(equalTo: photosContainer.topAnchor),
            photosCollectionView.leadingAnchor.constraint(equalTo: photosContainer.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: photosContainer.trailingAnchor),
            photosCollectionView.bottomAnchor.constraint(equalTo: photosContainer.bottomAnchor),
            photosCollectionView.heightAnchor.constraint(equalToConstant: Constants.heightStandart)
        ])
    }
}
