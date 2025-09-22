//
//  RecipeWatchController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

class RecipeWatchController: BaseController {
    
    var recipeId: UUID?
    private var recipe: RecipeSupabase?
    private var ingredients: [IngredientSupabase] = []
    private var instructions: [InstructionSupabase] = []
    private let dataService = DataService.shared
    
    private var tags: [String] = []
    private var categories: [CategorySupabase] = []
    
    private var averageRating: Double = 0
    private var userRating: Rating?
    
    private let recipeImageView = RecipeImageWithFavoriteView()
    
    private let customScrollView = UIScrollView(backgroundColor: .clear)
    override var scrollView: UIScrollView { customScrollView }
    private let stackView = UIStackView(
        axis: .vertical,
        alignment: .fill,
        spacing: Constants.spacingBig
    )

    private lazy var ingredientsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: IngredientCell.self, identifier: IngredientCell.id)
            ],
            delegate: self,
            dataSource: self
        )
        return tableView
    }()
    
    private lazy var stepsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: InstructionTextCell.self, identifier: InstructionTextCell.id),
                TableViewCellConfig(cellClass: InstructionImageCell.self, identifier: InstructionImageCell.id)
            ],
            delegate: self,
            dataSource: self
        )
        return tableView
    }()
    
    private lazy var tagsCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .dynamicSize(useLeftAlignedLayout: false, scrollDirection: .horizontal),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: TagCollectionViewCell.self, identifier: TagCollectionViewCell.id)
            ],
            delegate: self,
            dataSource: self,
            showsHorizontalScrollIndicator: false,
            showsVerticalScrollIndicator: false,
            isScrollEnabled: true,
        )
        return collectionView
    }()
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .verticalFixedSize(Constants.categoryCellSize),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: CategoryGridCell.self, identifier: CategoryGridCell.id),
            ],
            delegate: self,
            dataSource: self,
            isScrollEnabled: false
        )
        return collectionView
    }()

    private lazy var loadingIndicator = UIActivityIndicatorView.createIndicator(
        style: .medium,
        centerIn: view
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        loadRecipeData()
    }
    
    internal override func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


    private func loadRecipeData() {
        guard let recipeId = recipeId else { return }
        loadingIndicator.startAnimating()
        
        Task {
            do {
                let results = try await dataService.fetchRecipeDetails(recipeId: recipeId)
                DispatchQueue.main.async {
                    self.updateUI(with: results)
                    self.loadingIndicator.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    AlertManager.shared.showError(on: self, error: error)
                }
            }
        }
    }
    
    private func updateUI(with results: RecipeDetailsResponse) {
        recipe = results.recipe
        ingredients = results.ingredients
        instructions = results.instructions
        tags = results.tags
        categories = results.categories
        averageRating = results.averageRating
        userRating = results.userRating
        
        guard let recipe = recipe else { return }

        setupRecipeTitle(recipe.title)
        setupRecipeImageView(with: recipe)
        setupMetaStack(with: recipe)

        if let description = recipe.description {
            setupDescription(with: description)
        }

        if !categories.isEmpty {
            setupCategoriesSection()
        }

        if !tags.isEmpty {
            setupTagsSection()
        }
        
        setupIngredientsSection()
        setupInstructionsSection()
        setupRateButton()
    }

    private func setupRecipeImageView(with recipe: RecipeSupabase) {
        recipeImageView.heightAnchor.constraint(equalToConstant: view.frame.width / 1.5).isActive = true
        stackView.addArrangedSubview(recipeImageView)
        
        if let imagePath = recipe.imagePath {
            Task {
                do {
                    let image = await dataService.loadImage(from: imagePath, bucket: Bucket.recipes)
                    let isCreator = await checkIfCurrentUserIsCreator(recipe: recipe)
                    let isFavorite = try await dataService.isRecipeFavorite(recipeId: recipe.id)
                    
                    DispatchQueue.main.async {
                        self.recipeImageView.configure(
                            with: image,
                            isFavorite: isFavorite,
                            isCreator: isCreator,
                            recipeId: recipe.id,
                            parentViewController: self
                        )
                    }
                } 
            }
        }
    }
    
    private func setupRecipeTitle(_ title: String){
        let titleLabel = UILabel(
            text: title,
            font: .helveticalBold(withSize: 24),
            textColor: .black,
            textAlignment: .center,
            numberOfLines: 0
        )
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupMetaStack(with recipe: RecipeSupabase) {
        let metaStack = RecipeMetaStackView()
        metaStack.configure(with: recipe, averageRating: averageRating, recipeId: recipe.id)
        metaStack.delegate = self
        stackView.addArrangedSubview(metaStack)
    }

    private func setupDescription(with description: String) {
        let descriptionLabel = UILabel(
            text: description,
            font: .helveticalRegular(withSize: 16),
            textColor: .black,
            numberOfLines: 0
        )
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupCategoriesSection() {
        let titleLabel = UILabel(
            text: Resources.Strings.Titles.categories,
            font: .helveticalBold(withSize: 18),
            textColor: .black
        )
        stackView.addArrangedSubview(titleLabel)
        
        categoriesCollectionView.reloadData()
        let rows = ceil(Double(categories.count) / 3.0)
        let height = rows * 100 + (rows - 1) * 8
        
        categoriesCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        stackView.addArrangedSubview(categoriesCollectionView)
    }
    
    private func setupTagsSection() {
        let titleLabel = UILabel(
            text: Resources.Strings.Titles.tags,
            font: .helveticalBold(withSize: 18),
            textColor: .black
        )
        stackView.addArrangedSubview(titleLabel)
        
        tagsCollectionView.reloadData()
        tagsCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.addArrangedSubview(tagsCollectionView)
    }
    
    private func setupIngredientsSection() {
        let titleLabel = UILabel(
            text: Resources.Strings.Titles.ingredient,
            font: .helveticalBold(withSize: 20),
            textColor: .black,
            textAlignment: .center
        )
        stackView.addArrangedSubview(titleLabel)
        
        ingredientsTableView.reloadData()
        ingredientsTableView.layer.cornerRadius = Constants.cornerRadiusSmall
        stackView.addArrangedSubview(ingredientsTableView)
        ingredientsTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private func setupInstructionsSection() {
        let titleLabel = UILabel(
            text: Resources.Strings.Titles.cookingStages,
            font: .helveticalBold(withSize: 20),
            textColor: .black,
            textAlignment: .center
        )
        stackView.addArrangedSubview(titleLabel)
        
        stepsTableView.reloadData()
        stackView.addArrangedSubview(stepsTableView)
        stepsTableView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private func setupRateButton() {
        let rateButton = UIButton(
            title: userRating != nil ? "Изменить оценку" : "Оценить рецепт",
            backgroundColor: .systemOrange,
            titleColor: .white,
            cornerRadius: Constants.cornerRadiusSmall,
            target: self,
            action: #selector(rateButtonTapped)
        )
        rateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(rateButton)
    }
    
    @objc private func rateButtonTapped() {
        let rateVC = RecipeRatingController(recipeId: recipeId)
//        let rateVC = RecipeRatingController()
//        rateVC.recipeId = recipeId
//        rateVC.currentRating = userRating?.rating
//        rateVC.comment = userRating?.comment
        navigationController?.pushViewController(rateVC, animated: true)
    }
    
    private func checkIfCurrentUserIsCreator(recipe: RecipeSupabase) async -> Bool {
        do {
            guard let currentUserId = try await dataService.getCurrentUserId(),
                  let creatorId = UUID(uuidString: recipe.userId.uuidString.lowercased()) else {
                return false
            }
            return currentUserId == creatorId
        } catch {
            print("Ошибка получения текущего пользователя: \(error)")
            return false
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension RecipeWatchController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == stepsTableView {
            return instructions.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientsTableView {
            return ingredients.count
        } else {
            let instruction = instructions[section]
            return instruction.imagePath != nil ? 2 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ingredientsTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientCell.id, for: indexPath) as? IngredientCell else {
                return IngredientCell()
            }
            
            let ingredient = ingredients[indexPath.row]
            let newIngredient = IngredientData(name: ingredient.name, amount: ingredient.amount)
            let isAdded = ShoppingListManager.shared.contains(ingredient: newIngredient)
            
            cell.configure(with: newIngredient, isAdded: isAdded)
            cell.addActionHandler = { ShoppingListManager.shared.addIngredient($0) }
            
            DispatchQueue.main.async {
                tableView.dynamicHeightForTableView()
            }
            return cell
        } else {
            let instruction = instructions[indexPath.section]
            
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: InstructionTextCell.id, for: indexPath) as? InstructionTextCell else {
                    return InstructionTextCell()
                }
                cell.configure(stepNumber: instruction.stepNumber, description: instruction.description ?? "")
                DispatchQueue.main.async {
                    tableView.dynamicHeightForTableView()
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: InstructionImageCell.id, for: indexPath) as? InstructionImageCell else {
                    return InstructionImageCell()
                }
                if let imagePath = instruction.imagePath {
                    cell.configure(with: imagePath)
                    DispatchQueue.main.async {
                        tableView.dynamicHeightForTableView()
                    }
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        tableView != stepsTableView
    }
}

// MARK: UICollectionViewDataSource
extension RecipeWatchController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return tags.count
        } else {
            return categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.id, for: indexPath) as? TagCollectionViewCell else {
                return TagCollectionViewCell()
            }
            cell.configure(with: tags[indexPath.item],
                           showDelete: false)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryGridCell.id, for: indexPath) as? CategoryGridCell else {
                return CategoryGridCell()
            }
            cell.configure(with: categories[indexPath.item].title,
                           iconName: categories[indexPath.item].iconName,
                           isSelected: false)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagsCollectionView {
            let tag = tags[indexPath.item]
            let font = UIFont.helveticalRegular(withSize: 14)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (tag as NSString).size(withAttributes: attributes)
            return CGSize(width: size.width + 24, height: 30)
        } else {
            return Constants.categoryCellSize
        }
    }
}

extension RecipeWatchController: @preconcurrency RecipeMetaStackViewDelegate {
    func didTapRatingView(recipeId: UUID) {
        let reviewsVC = ReviewsViewController(recipeId: recipeId, averageRating: averageRating)
        navigationController?.pushViewController(reviewsVC, animated: true)
    }
}

