//
//  RateRecipeController.swift
//  Povareshka
//
//  Created by user on 23.06.2025.
//

import UIKit
import Supabase

final class RateRecipeController: UIViewController {
    
    // MARK: - Properties
    var recipeId: UUID?
    var currentRating: Int?
    var comment: String?
    var photos: [UIImage] = []
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let starsView = StarsRatingView()
    private let commentTextView = UITextView()
    private let photosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigation()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Оценить рецепт"
        
        // Настройка scrollView и stackView
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
        photosCollectionView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let addPhotoButton = UIButton(type: .system)
        addPhotoButton.setTitle("Добавить фото", for: .normal)
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(photosTitle)
        stackView.addArrangedSubview(photosCollectionView)
        stackView.addArrangedSubview(addPhotoButton)
        
        // Установка текущего рейтинга если есть
        if let currentRating = currentRating {
            starsView.setRating(currentRating)
        }
    }
    
    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: currentRating == nil ? "Оценить" : "Изменить",
            style: .done,
            target: self,
            action: #selector(saveRating)
        )
    }
    
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @objc private func saveRating() {
//        guard let recipeId = recipeId else { return }
//        
//        let rating = starsView.currentRating
//        guard rating > 0 else {
//            showAlert(title: "Ошибка", message: "Пожалуйста, поставьте оценку")
//            return
//        }
//        
//        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        Task {
//            do {
//                // Сохраняем оценку
//                let ratingData: [String: Any] = [
//                    "recipe_id": recipeId,
//                    "user_id": AuthManager.shared.currentUserId!,
//                    "rating": rating,
//                    "comment": comment.isEmpty ? nil : comment
//                ]
//                
//                if currentRating == nil {
//                    // Новая оценка
//                    try await SupabaseManager.shared.client
//                        .from("ratings")
//                        .insert(ratingData)
//                        .execute()
//                } else {
//                    // Обновление существующей оценки
//                    try await SupabaseManager.shared.client
//                        .from("ratings")
//                        .update(ratingData)
//                        .eq("recipe_id", value: recipeId)
//                        .eq("user_id", value: AuthManager.shared.currentUserId!)
//                        .execute()
//                }
//                
//                // Сохраняем фотографии если есть
//                if !photos.isEmpty {
//                    for (index, photo) in photos.enumerated() {
//                        guard let data = photo.jpegData(compressionQuality: 0.8) else { continue }
//                        
//                        let fileName = "\(UUID().uuidString).jpg"
//                        try await SupabaseManager.shared.client
//                            .storage
//                            .from("recipe_photos")
//                            .upload(
//                                path: "\(recipeId)/\(fileName)",
//                                file: data,
//                                options: FileOptions(contentType: "image/jpeg")
//                            )
//                        
//                        // Сохраняем ссылку на фото в базу
//                        try await SupabaseManager.shared.client
//                            .from("recipe_photos")
//                            .insert([
//                                "recipe_id": recipeId,
//                                "user_id": AuthManager.shared.currentUserId!,
//                                "photo_path": "\(recipeId)/\(fileName)",
//                                "order_index": index
//                            ])
//                            .execute()
//                    }
//                }
//                
//                DispatchQueue.main.async {
//                    self.navigationController?.popViewController(animated: true)
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    self.showAlert(title: "Ошибка", message: error.localizedDescription)
//                }
//            }
//        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension RateRecipeController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.configure(with: photos[indexPath.item])
        return cell
    }
}

// MARK: - UIImagePickerControllerDelegate
extension RateRecipeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            photos.append(image)
            photosCollectionView.reloadData()
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - Вспомогательные классы
final class StarsRatingView: UIStackView {
    private var stars = [UIButton]()
    var currentRating: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        axis = .horizontal
        spacing = 8
        distribution = .fillEqually
        
        for _ in 1...5 {
            let button = UIButton()
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
            button.tintColor = .systemOrange
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            addArrangedSubview(button)
            stars.append(button)
        }
    }
    
    func setRating(_ rating: Int) {
        currentRating = rating
        for (index, star) in stars.enumerated() {
            star.isSelected = index < rating
        }
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        guard let index = stars.firstIndex(of: sender) else { return }
        currentRating = index + 1
        for (i, star) in stars.enumerated() {
            star.isSelected = i <= index
        }
    }
}

final class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}
