//
//  FilterViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 13.03.2025.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ viewController: FilterViewController, didApplyFilters filters: RecipeFilters)
}

class FilterViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let timeRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "Время приготовления"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeRangeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 180
        slider.tintColor = AppColors.primaryOrange
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let timeValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Категории"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Применить", for: .normal)
        button.backgroundColor = AppColors.primaryOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private var selectedCategories: Set<String> = []
    private var selectedTime: Float = 30
    weak var delegate: FilterViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [timeRangeLabel, timeRangeSlider, timeValueLabel,
         categoriesLabel, categoriesCollectionView, applyButton].forEach {
            contentView.addSubview($0)
        }
        
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
            
            timeRangeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            timeRangeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            timeRangeSlider.topAnchor.constraint(equalTo: timeRangeLabel.bottomAnchor, constant: 16),
            timeRangeSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeRangeSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeValueLabel.topAnchor.constraint(equalTo: timeRangeSlider.bottomAnchor, constant: 8),
            timeValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            categoriesLabel.topAnchor.constraint(equalTo: timeValueLabel.bottomAnchor, constant: 24),
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: 16),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            applyButton.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: 24),
            applyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            applyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 50),
            applyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        timeRangeSlider.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        
        updateTimeLabel()
    }
    
    private func setupNavigationBar() {
        title = "ФИЛЬТРЫ"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сбросить", style: .plain, target: self, action: #selector(resetTapped))
    }
    
    private func setupCollectionView() {
        categoriesCollectionView.register(FilterCategoryCell.self, forCellWithReuseIdentifier: "FilterCategoryCell")
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
    }
    
    // MARK: - Actions
    @objc private func timeSliderChanged() {
        selectedTime = timeRangeSlider.value
        updateTimeLabel()
    }
    
    @objc private func applyButtonTapped() {
        let filters = RecipeFilters(
            maxCookingTime: Int(timeRangeSlider.value),
            categories: Array(selectedCategories)
        )
        delegate?.filterViewController(self, didApplyFilters: filters)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func resetTapped() {
        selectedCategories.removeAll()
        selectedTime = 30
        timeRangeSlider.value = selectedTime
        updateTimeLabel()
        categoriesCollectionView.reloadData()
    }
    
    private func updateTimeLabel() {
        timeValueLabel.text = "до \(Int(selectedTime)) мин"
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CategoryItem.mockCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCategoryCell.id, for: indexPath) as? FilterCategoryCell else {
            return FilterCategoryCell()
        }
        let category = CategoryItem.mockCategories[indexPath.item]
        cell.configure(with: category.title, isSelected: selectedCategories.contains(category.title))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 3
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = CategoryItem.mockCategories[indexPath.item].title
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

struct RecipeFilters {
    let maxCookingTime: Int
    let categories: [String]
}
