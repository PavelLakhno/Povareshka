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

class FilterViewController: BaseController {
    
    // MARK: - UI Components
    private let contentView = UIView(backgroundColor: .systemBackground)
    
    private let timeRangeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 180
        slider.tintColor = AppColors.primaryOrange
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private let timeRangeLabel = UILabel(text: AppStrings.Titles.timeCooking,
                                         font: .helveticalBold(withSize: 16))
    private let timeValueLabel = UILabel(text: AppStrings.Titles.categories,
                                         font: .helveticalRegular(withSize: 16))
    private let categoriesLabel = UILabel(text: AppStrings.Titles.categories,
                                          font: .helveticalBold(withSize: 16))
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .dynamicSize(useLeftAlignedLayout: true, scrollDirection: .vertical),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: FilterCategoryCell.self, identifier: FilterCategoryCell.id),
            ],
            delegate: self,
            dataSource: self,
            isScrollEnabled: false
        )
        return collectionView
    }()
    
    private lazy var applyButton = UIButton(
        title: AppStrings.Buttons.apply,
        backgroundColor: AppColors.primaryOrange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(applyButtonTapped)
    )
    
    // MARK: - Properties
    var selectedCategories: Set<String> = []
    var selectedTime: Float = 30
    weak var delegate: FilterViewControllerDelegate?
    private var allCategories: [CategorySupabase] = DataService.shared.categories
    
    private let customScrollView = UIScrollView(backgroundColor: AppColors.gray100)
    override var scrollView: UIScrollView { customScrollView }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        Task {
            await DataService.shared.loadCategories()
            allCategories = DataService.shared.categories
            categoriesCollectionView.reloadData()
            categoriesCollectionView.dynamicHeightForCollectionView()
        }
    }
    
    // MARK: - Setup
    override func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [timeRangeLabel, timeRangeSlider, timeValueLabel,
         categoriesLabel, categoriesCollectionView, applyButton].forEach {
            contentView.addSubview($0)
        }
        
        timeRangeSlider.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        
        timeRangeSlider.value = selectedTime
        updateTimeLabel()
    }
    
    override func setupConstraints() {
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
            
            timeRangeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.paddingWidth),
            timeRangeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            
            timeRangeSlider.topAnchor.constraint(equalTo: timeRangeLabel.bottomAnchor, constant: Constants.paddingMedium),
            timeRangeSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            timeRangeSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            
            timeValueLabel.topAnchor.constraint(equalTo: timeRangeSlider.bottomAnchor, constant: Constants.paddingSmall),
            timeValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            
            categoriesLabel.topAnchor.constraint(equalTo: timeValueLabel.bottomAnchor, constant: Constants.paddingWidth),
            categoriesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            
            categoriesCollectionView.topAnchor.constraint(equalTo: categoriesLabel.bottomAnchor, constant: Constants.paddingMedium),
            categoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            categoriesCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),//
            
            applyButton.topAnchor.constraint(equalTo: categoriesCollectionView.bottomAnchor, constant: Constants.paddingWidth),
            applyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.paddingMedium),
            applyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.paddingMedium),
            applyButton.heightAnchor.constraint(equalToConstant: Constants.height),
            applyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.paddingWidth)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = AppStrings.Titles.filter
        addNavBarButtons(at: .left, types: [.title(AppStrings.Buttons.cancel)])
        addNavBarButtons(at: .right, types: [.title(AppStrings.Buttons.reset)])
    }
    
    internal override func navBarLeftButtonHandler() {
        dismiss(animated: true)
    }
    
    internal override func navBarRightButtonHandler() {
        selectedCategories.removeAll()
        selectedTime = 30
        timeRangeSlider.value = selectedTime
        updateTimeLabel()
        categoriesCollectionView.reloadData()
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
    
    private func updateTimeLabel() {
        timeValueLabel.text = "до \(Int(selectedTime)) мин"
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCategoryCell.id, for: indexPath) as? FilterCategoryCell else {
            return FilterCategoryCell()
        }
        let category = allCategories[indexPath.item]
        cell.configure(with: category.title, isSelected: selectedCategories.contains(category.title))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = allCategories[indexPath.item]
        let textSize = category.title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
        let width = min(textSize.width + 32, (collectionView.bounds.width - 16) / 2)
        return CGSize(width: width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = allCategories[indexPath.item]
        let categoryTitle = category.title
        if selectedCategories.contains(categoryTitle) {
            selectedCategories.remove(categoryTitle)
        } else {
            selectedCategories.insert(categoryTitle)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}
