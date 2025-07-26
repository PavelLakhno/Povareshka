//
//  ReviewsViewController.swift
//  Povareshka
//
//  Created by user on 23.07.2025.
//

import UIKit

class ReviewsViewController: UIViewController {
    
    private let recipeId: UUID
    private var averageRating: Double
    private var ratings: [Rating] = []
    private var userProfiles: [UUID: UserProfile] = [:]
    private var reviewPhotos: [ReviewPhoto] = []
    private var filteredRatings: [Rating] = []
    private var sortOption: SortOption = .dateDesc
    
    enum SortOption {
        case dateDesc
        case dateAsc
        case ratingDesc
        case ratingAsc
        case withPhotos
        case withComments
    }
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let ratingHeaderView = RatingHeaderView()
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
    private let tableView = UITableView()
    private let sortButton = UIButton(type: .system)
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
        setupViews()
        loadData()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Отзывы и оценки"
        
        // Настройка индикатора загрузки
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Настройка scrollView и contentView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Настройка рейтинг хедера
        ratingHeaderView.configure(rating: averageRating)
        ratingHeaderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingHeaderView)
        
        // Настройка коллекции фото
        setupPhotosCollectionView()
        contentView.addSubview(photosCollectionView)
        
        // Кнопка "Просмотреть все"
        let viewAllButton = UIButton(type: .system)
        viewAllButton.setTitle("Просмотреть все", for: .normal)
        viewAllButton.addTarget(self, action: #selector(viewAllPhotos), for: .touchUpInside)
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewAllButton)
        
        // Настройка кнопки сортировки
        setupSortButton()
        contentView.addSubview(sortButton)
        
        // Настройка таблицы
        setupTableView()
        contentView.addSubview(tableView)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            ratingHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            ratingHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ratingHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            photosCollectionView.topAnchor.constraint(equalTo: ratingHeaderView.bottomAnchor, constant: 16),
            photosCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photosCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photosCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            viewAllButton.topAnchor.constraint(equalTo: photosCollectionView.bottomAnchor, constant: 8),
            viewAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            sortButton.topAnchor.constraint(equalTo: viewAllButton.bottomAnchor, constant: 16),
            sortButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sortButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 600) // Временное значение
        ])
    }
    
    private func setupPhotosCollectionView() {
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.register(ReviewPhotoCell.self, forCellWithReuseIdentifier: ReviewPhotoCell.id)
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupSortButton() {
        sortButton.setTitle("Сортировка: По дате (новые)", for: .normal)
        sortButton.addTarget(self, action: #selector(showSortOptions), for: .touchUpInside)
        sortButton.tintColor = .systemGray.withAlphaComponent(0.8)
        sortButton.layer.borderWidth = 1
        sortButton.layer.borderColor = UIColor.systemOrange.cgColor
        sortButton.layer.cornerRadius = 8
        sortButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.id)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Data Loading
    private func loadData() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                // Загружаем оценки и фотографии параллельно
                async let ratingsTask = loadRatings()
                async let photosTask = loadReviewPhotos()
                
                let (ratings, photos) = await (try ratingsTask, try photosTask)
                
                // Загружаем профили пользователей
                let userIds = ratings.map { $0.userId }
                let profiles = try await loadUserProfiles(userIds: userIds)
                
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
    
    private func updateUI() {
        // Обновляем коллекцию фото
        photosCollectionView.reloadData()
        
        // Обновляем таблицу
        tableView.reloadData()
        
        // Обновляем высоту таблицы
        let tableHeight = tableView.contentSize.height
        tableView.constraints.first { $0.firstAttribute == .height }?.constant = tableHeight
    }
    
    // MARK: - Sorting
    private func applySort() {
        switch sortOption {
        case .dateDesc:
            filteredRatings = ratings.sorted { $0.createdAt > $1.createdAt }
        case .dateAsc:
            filteredRatings = ratings.sorted { $0.createdAt < $1.createdAt }
        case .ratingDesc:
            filteredRatings = ratings.sorted { $0.rating > $1.rating }
        case .ratingAsc:
            filteredRatings = ratings.sorted { $0.rating < $1.rating }
        case .withPhotos:
            let ratingsWithPhotos = Set(reviewPhotos.map { $0.userId })
            filteredRatings = ratings.filter { ratingsWithPhotos.contains($0.userId) }
        case .withComments:
            filteredRatings = ratings.filter { $0.comment?.isEmpty == false }
        }
    }
    
    private func updateSortButtonTitle() {
        let title: String
        switch sortOption {
        case .dateDesc: title = "Сортировка: По дате (новые)"
        case .dateAsc: title = "Сортировка: По дате (старые)"
        case .ratingDesc: title = "Сортировка: По рейтингу (высокий)"
        case .ratingAsc: title = "Сортировка: По рейтингу (низкий)"
        case .withPhotos: title = "Сортировка: С фото"
        case .withComments: title = "Сортировка: С комментариями"
        }
        sortButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Actions
    @objc private func viewAllPhotos() {
        let allPhotos = reviewPhotos.map { $0.photoPath }
        guard !allPhotos.isEmpty else { return }
        
        let photoViewer = PhotoViewerController(photos: allPhotos)
        present(photoViewer, animated: true)
    }
    
    @objc private func showSortOptions() {
        let alert = UIAlertController(title: "Сортировка отзывов", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "По дате (новые)", style: .default, handler: { _ in
            self.sortOption = .dateDesc
            self.updateSortButtonTitle()
            self.applySort()
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "По дате (старые)", style: .default, handler: { _ in
            self.sortOption = .dateAsc
            self.updateSortButtonTitle()
            self.applySort()
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "По рейтингу (высокий)", style: .default, handler: { _ in
            self.sortOption = .ratingDesc
            self.updateSortButtonTitle()
            self.applySort()
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "По рейтингу (низкий)", style: .default, handler: { _ in
            self.sortOption = .ratingAsc
            self.updateSortButtonTitle()
            self.applySort()
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "С фото", style: .default, handler: { _ in
            self.sortOption = .withPhotos
            self.updateSortButtonTitle()
            self.applySort()
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "С комментариями", style: .default, handler: { _ in
            self.sortOption = .withComments
            self.updateSortButtonTitle()
            self.applySort()
            self.updateUI()
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ReviewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(reviewPhotos.count, 10) // Показываем максимум 10 фото
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewPhotoCell.id, for: indexPath) as! ReviewPhotoCell
        let photo = reviewPhotos[indexPath.item]
        cell.configure(with: photo.photoPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let allPhotos = reviewPhotos.map { $0.photoPath }
        let photoViewer = PhotoViewerController(photos: allPhotos, initialIndex: indexPath.item)
        present(photoViewer, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRatings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.id, for: indexPath) as! ReviewCell
        let rating = filteredRatings[indexPath.row]
        let userProfile = userProfiles[rating.userId]
        let userPhotos = reviewPhotos.filter { $0.userId == rating.userId }
        
        cell.configure(
            rating: rating,
            userProfile: userProfile,
            photos: userPhotos.map { $0.photoPath }
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
