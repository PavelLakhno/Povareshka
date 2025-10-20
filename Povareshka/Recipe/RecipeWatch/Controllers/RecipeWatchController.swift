//
//  RecipeWatchController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

final class RecipeWatchController: BaseController {
    
    var recipeId: UUID?

    private let viewModel = RecipeWatchViewModel()
    
    // Data Sources вместо прямого хранения данных
    private let ingredientsDataSource = IngredientsDataSource()
    private let instructionsDataSource = InstructionsDataSource()
    
    // НОВОЕ: Data Sources для коллекций
    private let tagsDataSource = TagsCollectionViewDataSource()
    private let categoriesDataSource = CategoriesCollectionViewDataSource()
    
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
            delegate: ingredientsDataSource,
            dataSource: ingredientsDataSource
        )
        return tableView
    }()
    
    private lazy var stepsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: InstructionTextCell.self, identifier: InstructionTextCell.id),
                TableViewCellConfig(cellClass: InstructionImageCell.self, identifier: InstructionImageCell.id)
            ],
            delegate: instructionsDataSource,
            dataSource: instructionsDataSource
        )
        return tableView
    }()
    
    private lazy var tagsCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .dynamicSize(useLeftAlignedLayout: false, scrollDirection: .horizontal),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: TagCollectionViewCell.self, identifier: TagCollectionViewCell.id)
            ],
            delegate: tagsDataSource,
            dataSource: tagsDataSource,
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
            delegate: categoriesDataSource,
            dataSource: categoriesDataSource,
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
            await viewModel.loadRecipe(recipeId: recipeId)
            updateUI()
        }
    }
    
    @MainActor
    private func updateUI() {
        guard let recipe = viewModel.recipe else { return }

        // Обновляем Data Sources из ViewModel
        ingredientsDataSource.updateIngredients(viewModel.ingredients)
        instructionsDataSource.updateInstructions(viewModel.instructions)
        
        tagsDataSource.updateTags(viewModel.tags)
        categoriesDataSource.updateCategories(viewModel.categories)
        
        // Очищаем stackView
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Строим UI на основе ViewModel
        setupRecipeTitle(recipe.title)
        setupRecipeImageView(with: recipe)
        setupMetaStack(with: recipe)

        if viewModel.hasDescription, let description = recipe.description {
            setupDescription(with: description)
        }

        if viewModel.hasCategories {
            setupCategoriesSection()
        }

        if viewModel.hasTags {
            setupTagsSection()
        }
        
        setupIngredientsSection()
        setupInstructionsSection()
        setupRateButton()
        
        loadingIndicator.stopAnimating()
    }
    


    private func setupRecipeImageView(with recipe: RecipeSupabase) {
        recipeImageView.heightAnchor.constraint(equalToConstant: view.frame.width / 1.5).isActive = true
        stackView.addArrangedSubview(recipeImageView)
        
        let loadImageIndicator = UIActivityIndicatorView.createIndicator(
            style: .medium,
            centerIn: recipeImageView
        )
        loadImageIndicator.startAnimating()

        Task { [unowned self] in
            do {
                let image = await viewModel.loadRecipeImage(for: recipe)
                let isFavorite = try await viewModel.checkIfRecipeIsFavorite(recipeId: recipe.id)
                let isCreator = await viewModel.checkIfCurrentUserIsCreator(recipe: recipe)
                
                DispatchQueue.main.async {
                    self.recipeImageView.configure(
                        with: image,
                        isFavorite: isFavorite,
                        isCreator: isCreator,
                        recipeId: recipe.id,
                        parentViewController: self
                    )
                    loadImageIndicator.stopAnimating()
                }
            }
        }
    }
    
    private func setupRecipeTitle(_ title: String){
        let titleLabel = UILabel(
            text: title,
            font: .helveticalBold(withSize: 24),
            textAlignment: .center,
            numberOfLines: 0
        )
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupMetaStack(with recipe: RecipeSupabase) {
        let metaStack = RecipeMetaStackView()
        metaStack.configure(with: recipe, averageRating: viewModel.averageRating, recipeId: recipe.id)
        metaStack.delegate = self
        stackView.addArrangedSubview(metaStack)
    }

    private func setupDescription(with description: String) {
        let descriptionLabel = UILabel(
            text: description,
            font: .helveticalRegular(withSize: 16),
            numberOfLines: 0
        )
        stackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupCategoriesSection() {
        let titleLabel = UILabel(
            text: AppStrings.Titles.categories,
            font: .helveticalBold(withSize: 18),
            textColor: .black
        )
        stackView.addArrangedSubview(titleLabel)
        
        categoriesCollectionView.reloadData()
        let rows = ceil(Double(viewModel.categories.count) / 3.0)
        let height = rows * 100 + (rows - 1) * 8
        
        categoriesCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        stackView.addArrangedSubview(categoriesCollectionView)
    }
    
    private func setupTagsSection() {
        let titleLabel = UILabel(
            text: AppStrings.Titles.tags,
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
            text: AppStrings.Titles.ingredient,
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
            text: AppStrings.Titles.cookingStages,
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
            title: viewModel.userRating != nil ? "Изменить оценку" : "Оценить рецепт",
            backgroundColor: AppColors.primaryOrange,
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
        navigationController?.pushViewController(rateVC, animated: true)
    }
}

extension RecipeWatchController: @preconcurrency RecipeMetaStackViewDelegate {
    func didTapRatingView(recipeId: UUID) {
        let reviewsVC = ReviewsViewController(recipeId: recipeId, averageRating: viewModel.averageRating)
        navigationController?.pushViewController(reviewsVC, animated: true)
    }
}

