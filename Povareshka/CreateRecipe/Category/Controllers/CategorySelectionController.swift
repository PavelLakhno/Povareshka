//
//  CategorySelectionController.swift
//  Povareshka
//
//  Created by user on 26.06.2025.
//

import UIKit

//final class CategoriesSelectionController: UITableViewController {
//    
//    var categories: [RecipeCategory] = RecipeCategory.allCategories()
//    var selectedCategories: [String] = []
//    var completion: (([String]) -> Void)?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupTableView()
//        setupNavigation()
//    }
//    
//    private func setupTableView() {
//        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.id)
//        tableView.rowHeight = 56
//        tableView.separatorStyle = .none
//    }
//    
//    private func setupNavigation() {
//        title = "Выберите категории"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            title: "Готово",
//            style: .done,
//            target: self,
//            action: #selector(doneTapped)
//        )
//    }
//    
//    // MARK: - TableView DataSource
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return categories.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.id, for: indexPath) as! CategoryCell
//        cell.configure(with: categories[indexPath.row])
//        return cell
//    }
//    
//    // MARK: - TableView Delegate
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        categories[indexPath.row].isSelected.toggle()
//        tableView.reloadRows(at: [indexPath], with: .automatic)
//    }
//    
//    // MARK: - Actions
//    
//    @objc private func doneTapped() {
//        selectedCategories = categories.filter { $0.isSelected }.map { $0.title }
//        completion?(selectedCategories)
//        navigationController?.popViewController(animated: true)
//    }
//}



// Part2
//final class CategoriesSelectionController: UIViewController {
//    private var allCategories: [RecipeCategory]
//    private var selectedCategories: [RecipeCategory]
//    var completion: (([RecipeCategory]) -> Void)?
//    
//    private lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumInteritemSpacing = 8
//        layout.minimumLineSpacing = 8
//        
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.register(CategoryGridCell.self, forCellWithReuseIdentifier: CategoryGridCell.id)
//        cv.dataSource = self
//        cv.delegate = self
//        cv.backgroundColor = .systemBackground
//        return cv
//    }()
//    
//    init(allCategories: [RecipeCategory], selectedCategories: [RecipeCategory]) {
//        self.allCategories = allCategories
//        self.selectedCategories = selectedCategories
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupView()
//        setupNavigation()
//    }
//    
//    private func setupView() {
//        view.addSubview(collectionView)
//        collectionView.frame = view.bounds
//    }
//    
//    private func setupNavigation() {
//        title = "Выберите категории"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
////            title: "Готово",
//            image: UIImage(systemName: "checkmark"),
//            style: .done,
//            target: self,
//            action: #selector(doneTapped)
//        )
//    }
//    
//    @objc private func doneTapped() {
//        completion?(selectedCategories)
//        navigationController?.popViewController(animated: true)
//    }
//}
//
//extension CategoriesSelectionController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return allCategories.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryGridCell.id, for: indexPath) as! CategoryGridCell
//        let category = allCategories[indexPath.item]
//        let isSelected = selectedCategories.contains { $0.title == category.title }
//        cell.configure(with: category.title, iconName: category.iconName, isSelected: isSelected)
//        return cell
//    }
//}
//
//extension CategoriesSelectionController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let category = allCategories[indexPath.item]
//        if let index = selectedCategories.firstIndex(where: { $0.title == category.title }) {
//            selectedCategories.remove(at: index)
//        } else {
//            selectedCategories.append(category)
//        }
//        collectionView.reloadItems(at: [indexPath])
//    }
//}
//
//extension CategoriesSelectionController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView,
//                       layout collectionViewLayout: UICollectionViewLayout,
//                       sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let padding: CGFloat = 16 * 2
//        let spacing: CGFloat = 8 * 2
//        let availableWidth = collectionView.bounds.width - padding - spacing
//        let cellWidth = availableWidth / 3
//        return CGSize(width: cellWidth, height: 100)
//    }
//}

final class CategoriesSelectionController: UIViewController {
    private var allCategories: [CategorySupabase]
    private var selectedCategories: [CategorySupabase]
    var completion: (([CategorySupabase]) -> Void)?
    
    private var isTableViewMode = false {
        didSet {
            updateViewMode()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CategoryGridCell.self, forCellWithReuseIdentifier: CategoryGridCell.id)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .systemBackground
        return cv
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.id)
        tv.rowHeight = 56
        tv.separatorStyle = .none
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
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
        setupView()
        setupNavigation()
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
    }
    
    private func setupNavigation() {
        title = "Выберите категории"
        
        let switchButton = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(toggleViewMode))
        
        let doneButton = UIBarButtonItem(
            image: UIImage(systemName: "checkmark"),
            style: .done,
            target: self,
            action: #selector(doneTapped))

        navigationItem.rightBarButtonItems = [doneButton, switchButton]
    }
    
    private func updateViewMode() {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if self.isTableViewMode {
                self.collectionView.removeFromSuperview()
                self.view.addSubview(self.tableView)
                self.tableView.frame = self.view.bounds
                self.tableView.reloadData()
            } else {
                self.tableView.removeFromSuperview()
                self.view.addSubview(self.collectionView)
                self.collectionView.frame = self.view.bounds
                self.collectionView.reloadData()
            }
        }, completion: nil)
        
        // Обновляем иконку кнопки с анимацией
        UIView.animate(withDuration: 0.2) {
            self.navigationItem.rightBarButtonItems?[1].image = UIImage(
                systemName: self.isTableViewMode ? "square.grid.2x2" : "list.bullet")
        }
    }

    
    @objc private func toggleViewMode() {
        isTableViewMode.toggle()
    }
    
    @objc private func doneTapped() {
        completion?(selectedCategories)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Collection View
extension CategoriesSelectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryGridCell.id, for: indexPath) as! CategoryGridCell
        let category = allCategories[indexPath.item]
        let isSelected = selectedCategories.contains { $0.title == category.title }
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
        return CGSize(width: cellWidth, height: 100)
    }
}

// MARK: - Table View
extension CategoriesSelectionController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.id, for: indexPath) as! CategoryCell
        let category = allCategories[indexPath.row]
        let isSelected = selectedCategories.contains { $0.title == category.title }
        cell.configure(with: category, isSelected: isSelected)
        return cell
    }
}

extension CategoriesSelectionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = allCategories[indexPath.row]
        toggleSelection(for: category)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Common Logic
extension CategoriesSelectionController {
    private func toggleSelection(for category: CategorySupabase) {
        if let index = selectedCategories.firstIndex(where: { $0.title == category.title }) {
            selectedCategories.remove(at: index)
        } else {
            selectedCategories.append(category)
        }
    }
}
