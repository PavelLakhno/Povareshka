//
//  ReviewsViewController.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

// MARK: - ReviewsViewController
final class ReviewsViewController: BaseController {
    
    // MARK: - Properties
    private let recipeId: UUID
    private var averageRating: Double
    private var ratings: [Rating] = []
    private var userProfiles: [UUID: UserProfile] = [:]
    private var reviewPhotos: [ReviewPhoto] = []
    private var filteredRatings: [Rating] = []
    private var sortOption: SortOption = .dateDesc
    
    // MARK: - UI Elements
    private let customScrollView = UIScrollView(backgroundColor: Resources.Colors.backgroundLight)
    override var scrollView: UIScrollView { customScrollView }
    
    private let contentView = UIView(backgroundColor: Resources.Colors.backgroundLight)
    private let ratingHeaderView = RatingHeaderView(backgroundColor: .systemBackground,
                                                    cornerRadius: Constants.cornerRadiusBig)
    private let photosSectionView = UIView(backgroundColor: .systemBackground,
                                           cornerRadius: Constants.cornerRadiusBig)
    
    private lazy var photosCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .horizontalFixedSize(Constants.categoryCellSize, insets: Constants.insentsRightLeftSides),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: ReviewPhotoCell.self, identifier: ReviewPhotoCell.id),
            ],
            delegate: self,
            dataSource: self
        )
        return collectionView
    }()

    private lazy var sortButton = UIButton(title: RatingsSorter.title(for: sortOption),
                                           backgroundColor: .systemBackground,
                                           titleColor: .label,
                                           font: .helveticalRegular(withSize: 16),
                                           cornerRadius: Constants.cornerRadiusBig,
                                           target: self,
                                           action: #selector(showSortOptions))
    
    private lazy var viewAllButton = UIButton(title: Resources.Strings.Buttons.watchPhotos,
                                              titleColor: Resources.Colors.orange,
                                           font: .helveticalRegular(withSize: 14),
                                           target: self,
                                           action: #selector(viewAllPhotos))

    private lazy var tableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: ReviewCell.self, identifier: ReviewCell.id),
            ],
            delegate: self,
            dataSource: self,
            backgroundColor: .systemBackground,
            isScrollEnabled: false,
            separatorStyle: .singleLine,
            cornerRadius: Constants.cornerRadiusBig
        )
        return tableView
    }()

    private lazy var activityIndicator = UIActivityIndicatorView.createIndicator(
        style: .medium,
        centerIn: view
    )
//    private let activityIndicator: UIActivityIndicatorView = {
//        let indicator = UIActivityIndicatorView(style: .medium)
//        indicator.hidesWhenStopped = true
//        indicator.color = Resources.Colors.orange
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        return indicator
//    }()
    
    private let dataService = DataService.shared
    
    // MARK: - Init
    init(recipeId: UUID, averageRating: Double) {
        self.recipeId = recipeId
        self.averageRating = averageRating
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
        loadData()
    }
}

// MARK: - Setup
extension ReviewsViewController {
    private func setupNavigationBar() {
        navigationItem.title = Resources.Strings.Titles.feedback
        addNavBarButtons(at: .left, types: [.title(Resources.Strings.Buttons.cancel)])
    }
    
    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = Resources.Colors.backgroundLight
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        
        ratingHeaderView.configure(rating: averageRating)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(ratingHeaderView)
        contentView.addSubview(photosSectionView)
        contentView.addSubview(sortButton)
        contentView.addSubview(tableView)
        
        photosSectionView.addSubview(photosCollectionView)
        photosSectionView.addSubview(viewAllButton)
    }
    
    override internal func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            ratingHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingSmall),
            ratingHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            ratingHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium)
        ])

        NSLayoutConstraint.activate([
            photosSectionView.topAnchor.constraint(equalTo: ratingHeaderView.bottomAnchor, constant: Constants.paddingSmall),
            photosSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            photosSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            photosSectionView.heightAnchor.constraint(equalToConstant: Constants.photosSectionHeight),
            
            photosCollectionView.topAnchor.constraint(equalTo: photosSectionView.topAnchor, constant: Constants.paddingSmall),
            photosCollectionView.leadingAnchor.constraint(equalTo: photosSectionView.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: photosSectionView.trailingAnchor),
            photosCollectionView.heightAnchor.constraint(equalToConstant: Constants.photoCollectionHeight),
            
            viewAllButton.topAnchor.constraint(equalTo: photosCollectionView.bottomAnchor, constant: Constants.paddingSmall),
            viewAllButton.trailingAnchor.constraint(equalTo: photosSectionView.trailingAnchor, constant: -Constants.paddingMedium),
            viewAllButton.bottomAnchor.constraint(equalTo: photosSectionView.bottomAnchor, constant: -Constants.paddingSmall)
        ])

        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: photosSectionView.bottomAnchor, constant: Constants.paddingSmall),
            sortButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            sortButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: Constants.paddingSmall),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingMedium),
            tableView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
}

// MARK: - Data Loading
private extension ReviewsViewController {
    func loadData() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                async let ratingsTask = dataService.loadRatings(recipeId: recipeId)
                async let photosTask = dataService.loadReviewPhotos(recipeId: recipeId)
                
                let (ratings, photos) = await (try ratingsTask, try photosTask)
                let profiles = try await dataService.loadUserProfiles(userIds: ratings.map { $0.userId })
                
                DispatchQueue.main.async {
                    self.ratings = ratings
                    self.reviewPhotos = photos
                    self.userProfiles = profiles
                    self.applySort()
                    self.updateUI()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    AlertManager.shared.show(
                        on: self,
                        title: Resources.Strings.Alerts.errorTitle,
                        message: Resources.Strings.Messages.failedDownload
                    )

                }
            }
        }
    }
    
    func updateUI() {
        photosCollectionView.reloadData()
        tableView.reloadData()
        tableView.dynamicHeightForTableView()
    }
}

// MARK: - Sorting Logic
extension ReviewsViewController {
    enum SortOption {
        case dateDesc, dateAsc, ratingDesc, ratingAsc, withPhotos, withComments
    }
    
    private func applySort() {
        filteredRatings = RatingsSorter.sorted(ratings: ratings, by: sortOption, photos: reviewPhotos)
    }
    
    private func updateSortButtonTitle() {
        sortButton.setTitle(RatingsSorter.title(for: sortOption), for: .normal)
    }
    
    @objc private func showSortOptions() {
        let alert = RatingsSorter.sortAlertController(currentOption: sortOption) { [weak self] option in
            self?.sortOption = option
            self?.updateSortButtonTitle()
            self?.applySort()
            self?.updateUI()
        }
        present(alert, animated: true)
    }
}

// MARK: - Actions
extension ReviewsViewController {
    @objc private func viewAllPhotos() {
        guard !reviewPhotos.isEmpty else { return }
        let photoViewer = PhotoViewerController(photos: reviewPhotos.map { $0.photoPath })
        present(photoViewer, animated: true)
    }
    
    internal override func navBarLeftButtonHandler() {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - CollectionView DataSource & Delegate
extension ReviewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(reviewPhotos.count, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewPhotoCell.id, for: indexPath) as? ReviewPhotoCell else {
            return ReviewPhotoCell()
        }
        cell.configure(with: reviewPhotos[indexPath.item].photoPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewer = PhotoViewerController(
            photos: reviewPhotos.map { $0.photoPath },
            initialIndex: indexPath.item
        )
        present(photoViewer, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRatings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.id, for: indexPath) as? ReviewCell else {
            return ReviewCell()
        }
        let rating = filteredRatings[indexPath.row]
        let userProfile = userProfiles[rating.userId]
        let photos = reviewPhotos.filter { $0.userId == rating.userId }.map { $0.photoPath }

        cell.configure(
            with: rating,
            userProfile: userProfile,
            photos: photos
        )

        cell.layer.cornerRadius = Constants.cornerRadiusBig
        cell.contentView.layer.masksToBounds = true
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

