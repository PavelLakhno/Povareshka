//
//  CategorySelectionController.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

final class CategoriesSelectionController: BaseController {
    private var allCategories: [CategorySupabase]
    private var selectedCategories: [CategorySupabase]
    
    private var isTableViewMode = false {
        didSet {
            updateViewMode()
        }
    }
   
    private lazy var collectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .verticalFixedSize(insets: Constants.insetsAllSides),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: CategoryGridCell.self, identifier: CategoryGridCell.id),
            ],
            delegate: self,
            dataSource: self,
            backgroundColor: .white, 
        )
        return collectionView
    }()

    
    private lazy var tableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: CategoryCell.self, identifier: CategoryCell.id),
            ],
            delegate: self,
            dataSource: self,
            isScrollEnabled: true
        )
        return tableView
    }()
    
    var completion: (([CategorySupabase]) -> Void)?
    
    init(allCategories: [CategorySupabase], selectedCategories: [CategorySupabase]) {
        self.allCategories = allCategories
        self.selectedCategories = selectedCategories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    internal override func setupViews() {
        super.setupViews()
        view.addSubview(collectionView)
        setupNavigation()
    }
    
    override internal func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigation() {
        navigationItem.title = AppStrings.Titles.selectCategories
        addNavBarButtons(at: .left, types: [.title(AppStrings.Buttons.cancel)])
        
        let switchButton = UIBarButtonItem(
            image: AppImages.Icons.table,
            style: .plain,
            target: self,
            action: #selector(toggleViewMode)
        )

        let doneButton = UIBarButtonItem(
            title: AppStrings.Buttons.done,
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        navigationItem.rightBarButtonItems = [doneButton, switchButton]
    }
    
    private func updateViewMode() {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if self.isTableViewMode {
                self.collectionView.removeFromSuperview()
                self.view.addSubview(self.tableView)
                NSLayoutConstraint.activate([
                    self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                    self.tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                    self.tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                    self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                ])
                self.tableView.reloadData()
            } else {
                self.tableView.removeFromSuperview()
                self.view.addSubview(self.collectionView)
                NSLayoutConstraint.activate([
                    self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                    self.collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
                    self.collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
                    self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                ])
                self.collectionView.reloadData()
            }
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2) {
            self.navigationItem.rightBarButtonItems?[1].image = self.isTableViewMode ?
            AppImages.Icons.collection : AppImages.Icons.table
        }
        
    }
    
    @objc private func toggleViewMode() {
        isTableViewMode.toggle()
    }
    
    @objc private func doneTapped() {
        completion?(selectedCategories)
        navigationController?.popViewController(animated: true)
    }

    internal override func navBarLeftButtonHandler() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Collection View
extension CategoriesSelectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryGridCell.id, for: indexPath) as? CategoryGridCell else {
            return CategoryGridCell()
        }
        let category = allCategories[indexPath.item]
        let isSelected = selectedCategories.contains { $0.id == category.id }
        cell.configure(with: category.title, iconName: category.iconName, isSelected: isSelected)
        return cell
    }
}

extension CategoriesSelectionController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = allCategories[indexPath.item]
        toggleSelection(for: category)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension CategoriesSelectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 * 2
        let spacing: CGFloat = 8 * 2
        let availableWidth = collectionView.bounds.width - padding - spacing
        let cellWidth = availableWidth / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - UITableViewDataSource
extension CategoriesSelectionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.id, for: indexPath) as? CategoryCell else {
            return CategoryCell()
        }
        let category = allCategories[indexPath.row]
        let isSelected = selectedCategories.contains { $0.id == category.id }
        cell.configure(with: category, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = allCategories[indexPath.row]
        toggleSelection(for: category)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

// MARK: - Common Logic
extension CategoriesSelectionController {
    private func toggleSelection(for category: CategorySupabase) {
        if let index = selectedCategories.firstIndex(where: { $0.id == category.id }) {
            selectedCategories.remove(at: index)
        } else {
            if selectedCategories.count >= 5 {
                AlertManager.shared.show(
                    on: self,
                    title: AppStrings.Alerts.errorTitle,
                    message: AppStrings.Alerts.maxCategories
                )
                return
            }
            selectedCategories.append(category)
        }
    }
}
