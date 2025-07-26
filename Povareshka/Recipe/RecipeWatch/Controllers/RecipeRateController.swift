//
//  RecipeRateController.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit
import Supabase

final class RecipeRateController: UIViewController {
    
    // MARK: - Properties
    var recipeId: UUID?
    var currentRating: Int?
    var comment: String?
    
    // Только для отображениыя
    var photos: [UIImage] = []
    
    // Для работы с сервером
    private var serverPhotoPaths: [String] = [] // Пути уже загруженных фото
    private var photosToDelete: [String] = []   // Пути фото для удаления
    private var newPhotos: [UIImage] = []       // Новые фото для загрузки
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let starsView = RatingView()
    private let commentTextView = UITextView()
    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
        loadCurrentRating()
        loadReviewPhotos()
    }
    
    // MARK: - Private Methods
    private func loadCurrentRating() {
        guard let recipeId = recipeId else { return }
        
        Task {
            do {
                let rating = try await RatingManager.shared.getUserRating(for: recipeId)
                DispatchQueue.main.async {
                    self.currentRating = rating?.rating
                    self.comment = rating?.comment
                    self.starsView.configure(with: rating?.rating ?? 0)
                    self.commentTextView.text = rating?.comment ?? ""
                    self.setupNavigation()
                }
            } catch {
                print("Ошибка загрузки оценки: \(error)")
            }
        }
    }
    

    
    private func loadReviewPhotos() {
        guard let recipeId = recipeId else { return }
        
        showPhotoLoadingState()
        
        Task {
            do {
                guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
                    throw RatingError.userNotAuthenticated
                }
                // 1. Получаем информацию о загруженных фото
                let photosInfo = try await RatingManager.shared.getReviewPhotosInfo(recipeId: recipeId, userId: userId)
                self.serverPhotoPaths = photosInfo.map { $0.photoPath }
                
                // 2. Загружаем сами изображения
                self.photos = try await RatingManager.shared.loadReviewPhotos(recipeId: recipeId, userId: userId)
                
                DispatchQueue.main.async {
                    self.hidePhotoLoadingState()
                    self.photosCollectionView.reloadData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.hidePhotoLoadingState()
                    self.showPhotoLoadingError()
                    print("Ошибка загрузки фото: \(error)")
                }
            }
        }
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Оценить рецепт"
        
        // Настройка scrollView и stackView
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Создаем контейнер для коллекции и индикаторов
        let photosContainer = UIView()
        photosContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем элементы в контейнер
        photosContainer.addSubview(photosCollectionView)
        photosContainer.addSubview(loadingIndicator)
        photosContainer.addSubview(errorLabel)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Констрейнты для контейнера фотографий
        NSLayoutConstraint.activate([
            // photosCollectionView заполняет весь контейнер
            photosCollectionView.topAnchor.constraint(equalTo: photosContainer.topAnchor),
            photosCollectionView.leadingAnchor.constraint(equalTo: photosContainer.leadingAnchor),
            photosCollectionView.trailingAnchor.constraint(equalTo: photosContainer.trailingAnchor),
            photosCollectionView.bottomAnchor.constraint(equalTo: photosContainer.bottomAnchor),
            photosCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            // Индикатор по центру контейнера
            loadingIndicator.centerXAnchor.constraint(equalTo: photosContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: photosContainer.centerYAnchor),
            
            // Лейбл ошибки с отступами
            errorLabel.leadingAnchor.constraint(equalTo: photosContainer.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: photosContainer.trailingAnchor, constant: -16),
            errorLabel.centerYAnchor.constraint(equalTo: photosContainer.centerYAnchor)
        ])
        
        // Основные констрейнты для scrollView и stackView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        
        // 1. Звезды рейтинга (обязательно)
        let starsTitle = UILabel()
        starsTitle.text = "Ваша оценка"
        starsTitle.font = .boldSystemFont(ofSize: 18)
        
        starsView.didSelectRating = { [weak self] rating in
            self?.currentRating = rating
        }
        
        stackView.addArrangedSubview(starsTitle)
        stackView.addArrangedSubview(starsView)
        
        // 2. Комментарий (опционально)
        let commentTitle = UILabel()
        commentTitle.text = "Комментарий (необязательно)"
        commentTitle.font = .boldSystemFont(ofSize: 18)
        
        commentTextView.layer.borderColor = UIColor.systemGray5.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.cornerRadius = 8
        commentTextView.font = .systemFont(ofSize: 16)
        commentTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        commentTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        commentTextView.text = comment
        
        stackView.addArrangedSubview(commentTitle)
        stackView.addArrangedSubview(commentTextView)
        
        // 3. Фотографии (опционально)
        let photosTitle = UILabel()
        photosTitle.text = "Фотографии (необязательно)"
        photosTitle.font = .boldSystemFont(ofSize: 18)
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        photosCollectionView.register(AddPhotoCell.self, forCellWithReuseIdentifier: AddPhotoCell.id)
//        photosCollectionView.register(AddCategoryGridCell.self, forCellWithReuseIdentifier: AddCategoryGridCell.id)
        
        // Добавляем контейнер вместо напрямую коллекции
        stackView.addArrangedSubview(photosTitle)
        stackView.addArrangedSubview(photosContainer)
        
        // Установка текущего рейтинга если есть
        if let currentRating = currentRating {
            starsView.configure(with: currentRating)
        }
        
        // Начальное состояние
        photosCollectionView.isHidden = true
        errorLabel.isHidden = true
    }
    
   
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: currentRating == nil ? "Оценить" : "Изменить",
            style: .done,
            target: self,
            action: #selector(saveRating)
        )
    }
    
    
    private func deletePhoto(at index: Int) {
        // Проверяем, удаляем ли существующее фото (есть путь) или новое (еще не загружено)
        if index < serverPhotoPaths.count {
            // Это существующее фото - добавляем путь в массив для удаления
            photosToDelete.append(serverPhotoPaths[index])
            serverPhotoPaths.remove(at: index)
        } else {
            // Это новое фото - удаляем из массива новых
            let newPhotoIndex = index - serverPhotoPaths.count
            if newPhotos.indices.contains(newPhotoIndex) {
                newPhotos.remove(at: newPhotoIndex)
            }
        }
        
        // Удаляем фото из основного массива для отображения
        photos.remove(at: index)
        
        // Обновляем коллекцию
        photosCollectionView.reloadData()
    }
    

    
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc private func saveRating() {
        guard let recipeId = recipeId, let rating = currentRating else {
            showAlert(title: "Ошибка", message: "Пожалуйста, поставьте оценку")
            return
        }
        
        let comment = commentTextView.text.isEmpty ? nil : commentTextView.text
        
        Task {
            do {
                // 1. Сначала сохраняем оценку и комментарий
                try await RatingManager.shared.submitRating(
                    recipeId: recipeId,
                    rating: rating,
                    comment: comment
                )
                

                
                // 2. Удаляем фото, помеченные на удаление
                if !photosToDelete.isEmpty {
                    try await RatingManager.shared.deletePhotos(paths: photosToDelete)
                }
                
                // 3. Если есть новые фото - загружаем только их
                if !newPhotos.isEmpty {
                    let _ = try await RatingManager.shared.uploadPhotos(
                        recipeId: recipeId,
                        photos: newPhotos
                    )
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Ошибка", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


// MARK: - UICollectionViewDataSource & Delegate
extension RecipeRateController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1 // +1 для кнопки добавления
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            // Ячейка для добавления фото
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddPhotoCell", for: indexPath) as! AddPhotoCell
            cell.addHandler = { [weak self] in
                self?.addPhotoTapped()
            }
            return cell
        } else {
            // Ячейка с фото
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            let photoIndex = indexPath.item - 1 // корректируем индекс
            
            if photos.indices.contains(photoIndex) {
                cell.configure(with: photos[photoIndex])
                cell.deleteHandler = { [weak self] in
                    self?.deletePhoto(at: photoIndex)
                }
            }
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RecipeRateController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photos.append(image)
            newPhotos.append(image)
            photosCollectionView.reloadData()
        }
        picker.dismiss(animated: true)
    }
}

// MARK: HelpMethods
extension RecipeRateController {
    private func showPhotoLoadingState() {
        // Можно добавить индикатор загрузки
        photosCollectionView.isHidden = true
        loadingIndicator.startAnimating()
    }

    private func hidePhotoLoadingState() {
        photosCollectionView.isHidden = false
        loadingIndicator.stopAnimating()
    }

    private func showPhotoLoadingError() {
        // Показать сообщение об ошибке
        errorLabel.text = "Не удалось загрузить фотографии"
        errorLabel.isHidden = false
    }
}

import Kingfisher

final class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let deleteButton = UIButton()
    var deleteHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Настройка imageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        addSubview(imageView)
        
        // Настройка кнопки удаления
        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.backgroundColor = .white
        deleteButton.layer.cornerRadius = 10
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        addSubview(deleteButton)
        
        // Констрейнты
        imageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func deleteTapped() {
        deleteHandler?()
    }
    
    func configure(with image: UIImage, showDelete: Bool = true) {
        imageView.image = image
        deleteButton.isHidden = !showDelete
    }
    
    func configure(with url: URL, showDelete: Bool = true) {
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "photo_placeholder"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
        deleteButton.isHidden = !showDelete
    }
}
