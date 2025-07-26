//
//  ReviewsViewController.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

// MARK: - RatingsSorter
struct RatingsSorter {
    static func sorted(ratings: [Rating], by option: ReviewsViewController.SortOption, photos: [ReviewPhoto]) -> [Rating] {
        switch option {
        case .dateDesc: return ratings.sorted { $0.createdAt > $1.createdAt }
        case .dateAsc: return ratings.sorted { $0.createdAt < $1.createdAt }
        case .ratingDesc: return ratings.sorted { $0.rating > $1.rating }
        case .ratingAsc: return ratings.sorted { $0.rating < $1.rating }
        case .withPhotos:
            let ratingsWithPhotos = Set(photos.map { $0.userId })
            return ratings.filter { ratingsWithPhotos.contains($0.userId) }
        case .withComments:
            return ratings.filter { $0.comment?.isEmpty == false }
        }
    }
    
    static func title(for option: ReviewsViewController.SortOption) -> String {
        switch option {
        case .dateDesc: return "Сортировка: По дате (новые)"
        case .dateAsc: return "Сортировка: По дате (старые)"
        case .ratingDesc: return "Сортировка: По рейтингу (высокий)"
        case .ratingAsc: return "Сортировка: По рейтингу (низкий)"
        case .withPhotos: return "Сортировка: С фото"
        case .withComments: return "Сортировка: С комментариями"
        }
    }
    
    @MainActor
    static func sortAlertController(
        currentOption: ReviewsViewController.SortOption,
        completion: @escaping (ReviewsViewController.SortOption) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: "Сортировка отзывов", message: nil, preferredStyle: .actionSheet)
        
        let options: [ReviewsViewController.SortOption] = [.dateDesc, .dateAsc, .ratingDesc, .ratingAsc, .withPhotos, .withComments]
        
        options.forEach { option in
            let action = UIAlertAction(title: title(for: option), style: .default) { _ in
                completion(option)
            }
            action.setValue(option == currentOption, forKey: "checked")
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        return alert
    }
}

// MARK: - Constants
private enum Constants {
    static let cornerRadius: CGFloat = 20
    static let smallPadding: CGFloat = 8
    static let mediumPadding: CGFloat = 16
    static let buttonHeight: CGFloat = 44
    static let photoCellSize = CGSize(width: 80, height: 80)
    static let photosSectionHeight: CGFloat = 132
    static let photoCollectionHeight: CGFloat = 100
}

// MARK: - ReviewsViewController
class ReviewsViewController: UIViewController {
    
    // MARK: - Properties
    private let recipeId: UUID
    private var averageRating: Double
    private var ratings: [Rating] = []
    private var userProfiles: [UUID: UserProfile] = [:]
    private var reviewPhotos: [ReviewPhoto] = []
    private var filteredRatings: [Rating] = []
    private var sortOption: SortOption = .dateDesc
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let ratingHeaderView = RatingHeaderView()
    private let photosSectionView = UIView()
    private let photosCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private let viewAllButton = UIButton(type: .system)
    private let sortButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
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
        setupUI()
        loadData()
    }
}

// MARK: - Setup
private extension ReviewsViewController {
    func setupUI() {
        view.backgroundColor = .neutral10
        title = "Отзывы и оценки"
        setupScrollView()
        setupRatingHeader()
        setupPhotosSection()
        setupSortButton()
        setupTableView()
        setupActivityIndicator()
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
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
    }
    
    func setupRatingHeader() {
        ratingHeaderView.configure(rating: averageRating)
        ratingHeaderView.backgroundColor = .systemBackground
        ratingHeaderView.layer.cornerRadius = Constants.cornerRadius
        ratingHeaderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingHeaderView)
        
        NSLayoutConstraint.activate([
            ratingHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.smallPadding),
            ratingHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.mediumPadding),
            ratingHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.mediumPadding)
        ])
    }
    
    func setupPhotosSection() {
        // Section container
        photosSectionView.backgroundColor = .systemBackground
        photosSectionView.layer.cornerRadius = Constants.cornerRadius
        photosSectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photosSectionView)
        
        // Collection View
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Constants.photoCellSize
        layout.minimumInteritemSpacing = Constants.smallPadding
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Constants.mediumPadding,
            bottom: 0,
            right: Constants.mediumPadding
        )
        
        photosCollectionView.collectionViewLayout = layout
        photosCollectionView.showsHorizontalScrollIndicator = false
        photosCollectionView.backgroundColor = .clear
        photosCollectionView.register(ReviewPhotoCell.self, forCellWithReuseIdentifier: ReviewPhotoCell.id)
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photosSectionView.addSubview(photosCollectionView)
        
        // View All Button
        viewAllButton.setTitle("Просмотреть все", for: .normal)
        viewAllButton.tintColor = .systemOrange
        viewAllButton.titleLabel?.font = .systemFont(ofSize: 14)
        viewAllButton.addTarget(self, action: #selector(viewAllPhotos), for: .touchUpInside)
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
        photosSectionView.addSubview(viewAllButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            photosSectionView.topAnchor.constraint(equalTo: ratingHeaderView.bottomAnchor, constant: Constants.smallPadding),
            photosSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.mediumPadding),
            photosSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.mediumPadding),
            photosSectionView.heightAnchor.constraint(equalToConstant: Constants.photosSectionHeight),
            
            photosCollectionView.topAnchor.constraint(equalTo: photosSectionView.topAnchor, constant: Constants.smallPadding),
            photosCollectionView.leadingAnchor.constraint(equalTo: photosSectionView.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: photosSectionView.trailingAnchor),
            photosCollectionView.heightAnchor.constraint(equalToConstant: Constants.photoCollectionHeight),
            
            viewAllButton.topAnchor.constraint(equalTo: photosCollectionView.bottomAnchor, constant: Constants.smallPadding),
            viewAllButton.trailingAnchor.constraint(equalTo: photosSectionView.trailingAnchor, constant: -Constants.mediumPadding),
            viewAllButton.bottomAnchor.constraint(equalTo: photosSectionView.bottomAnchor, constant: -Constants.smallPadding)
        ])
    }
    
    func setupSortButton() {
        sortButton.setTitle("Сортировка: По дате (новые)", for: .normal)
        sortButton.tintColor = .label
        sortButton.backgroundColor = .systemBackground
        sortButton.layer.cornerRadius = Constants.cornerRadius
        sortButton.titleLabel?.font = .systemFont(ofSize: 16)
        sortButton.addTarget(self, action: #selector(showSortOptions), for: .touchUpInside)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sortButton)
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: photosSectionView.bottomAnchor, constant: Constants.smallPadding),
            sortButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.mediumPadding),
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.mediumPadding),
            sortButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    func setupTableView() {
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.id)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: Constants.smallPadding),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.mediumPadding),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.mediumPadding),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.mediumPadding),
            tableView.heightAnchor.constraint(equalToConstant: 600)
        ])
    }
    
    func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Data Loading
private extension ReviewsViewController {
    func loadData() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                async let ratingsTask = loadRatings()
                async let photosTask = loadReviewPhotos()
                
                let (ratings, photos) = await (try ratingsTask, try photosTask)
                let profiles = try await loadUserProfiles(userIds: ratings.map { $0.userId })
                
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
                    self.showError(message: "Не удалось загрузить отзывы")
                }
            }
        }
    }
    
    private func loadRatings() async throws -> [Rating] {
        return try await SupabaseManager.shared.client
            .from("ratings")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    private func loadReviewPhotos() async throws -> [ReviewPhoto] {
        return try await SupabaseManager.shared.client
            .from("review_photos")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("order_index")
            .execute()
            .value
    }
    
    private func loadUserProfiles(userIds: [UUID]) async throws -> [UUID: UserProfile] {
        guard !userIds.isEmpty else { return [:] }
        
        let profiles: [UserProfile] = try await SupabaseManager.shared.client
            .from("profiles")
            .select()
            .in("id", values: userIds)
            .execute()
            .value
        
        var profilesDict: [UUID: UserProfile] = [:]
        profiles.forEach { profilesDict[$0.id] = $0 }
        return profilesDict
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
private extension ReviewsViewController {
    @objc func viewAllPhotos() {
        guard !reviewPhotos.isEmpty else { return }
        let photoViewer = PhotoViewerController(photos: reviewPhotos.map { $0.photoPath })
        present(photoViewer, animated: true)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CollectionView DataSource & Delegate
extension ReviewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(reviewPhotos.count, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewPhotoCell.id, for: indexPath) as! ReviewPhotoCell
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
//
// MARK: - TableView DataSource & Delegate
extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredRatings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.id, for: indexPath) as! ReviewCell
        let rating = filteredRatings[indexPath.row]
        let userProfile = userProfiles[rating.userId]
        let photos = reviewPhotos.filter { $0.userId == rating.userId }.map { $0.photoPath }
        
        cell.configure(
            rating: rating,
            userProfile: userProfile,
            photos: photos
        )
        
        // Cell styling
        cell.layer.cornerRadius = Constants.cornerRadius
        cell.contentView.layer.masksToBounds = true
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

