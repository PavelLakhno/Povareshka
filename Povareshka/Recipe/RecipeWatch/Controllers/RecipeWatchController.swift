//
//  RecipeWatchController.swift
//  Povareshka
//
//  Created by user on 02.11.2025.
//

import UIKit

final class RecipeWatchController: BaseController {
    
    // MARK: - Properties
    enum RecipeSource {
        case online(UUID)
        case offline(RecipeModel)
    }
    
    var recipeSource: RecipeSource?
    private var viewModel = RecipeWatchViewModel()
    private let storageManager = StorageManager.shared
    
    // Data Sources
    private let ingredientsDataSource = IngredientsDataSource()
    private let instructionsDataSource = InstructionsDataSource()
    private let tagsDataSource = TagsCollectionViewDataSource()
    private let categoriesDataSource = CategoriesCollectionViewDataSource()
    
    // UI Components
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
            isScrollEnabled: true
        )
        return collectionView
    }()
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .verticalFixedSize(Constants.viewSize100),
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
    
    private let offlineBadge: UILabel = {
        let label = UILabel()
        label.text = "OFFLINE"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .systemGray
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupDataSources()
        loadRecipeData()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        // Настраиваем бейдж оффлайн режима
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: offlineBadge)
        NSLayoutConstraint.activate([
            offlineBadge.widthAnchor.constraint(equalToConstant: 80),
            offlineBadge.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Настраиваем кнопки сохранения/удаления только для онлайн рецептов
        if case .online(let recipeId) = recipeSource {
            let isSaved = storageManager.isRecipeSaved(recipeId)
            addNavBarButtons(
                at: .right,
                types: !isSaved ? [.title(AppStrings.Buttons.save)] : [.title(AppStrings.Buttons.delete)]
            )
        } else {
            // Для оффлайн рецептов скрываем кнопки
            addNavBarButtons(at: .right, types: [])
        }
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
    
    private func setupDataSources() {
        ingredientsDataSource.onAddIngredient = { [weak self] ingredient in
            self?.addIngredientToShoppingList(ingredient)
        }
    }
    
    // MARK: - Data Loading
    private func loadRecipeData() {
        guard let recipeSource = recipeSource else { return }
        
        loadingIndicator.startAnimating()
        
        Task {
            switch recipeSource {
            case .online(let recipeId):
                await viewModel.loadOnlineRecipe(recipeId: recipeId)
            case .offline(let recipeModel):
                await viewModel.loadOfflineRecipe(recipeModel: recipeModel)
            }
            updateUI()
        }
    }
    
    @MainActor
    private func updateUI() {
        guard viewModel.hasData else { return }
        
        // Обновляем Data Sources
        ingredientsDataSource.updateIngredients(viewModel.ingredients)
        instructionsDataSource.updateInstructions(viewModel.instructions)
        tagsDataSource.updateTags(viewModel.tags)
        categoriesDataSource.updateCategories(viewModel.categories)
        
        // Очищаем stackView
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Настраиваем UI в зависимости от типа рецепта
        setupOfflineBadge()
        setupRecipeTitle()
        setupRecipeImageView()
        setupMetaStack()

        if viewModel.hasDescription {
            setupDescription()
        }

        if viewModel.hasCategories {
            setupCategoriesSection()
        }

        if viewModel.hasTags {
            setupTagsSection()
        }
        
        setupIngredientsSection()
        setupInstructionsSection()
        
        if viewModel.isOnline {
            setupRateButton()
        }
        
        loadingIndicator.stopAnimating()
    }
    
    private func setupOfflineBadge() {
        offlineBadge.isHidden = viewModel.isOnline
    }
    
    private func setupRecipeTitle() {
        let titleLabel = UILabel(
            text: viewModel.title,
            font: .helveticalBold(withSize: 24),
            textAlignment: .center,
            numberOfLines: 0
        )
        stackView.addArrangedSubview(titleLabel)
    }
    
    private func setupRecipeImageView() {
        recipeImageView.heightAnchor.constraint(equalToConstant: view.frame.width / 1.5).isActive = true
        stackView.addArrangedSubview(recipeImageView)
        
        let loadImageIndicator = UIActivityIndicatorView.createIndicator(
            style: .medium,
            centerIn: recipeImageView
        )
        loadImageIndicator.startAnimating()

        Task { [weak self] in
            guard let self = self else { return }
            
            let image = await viewModel.loadRecipeImage()
            let isFavorite = await viewModel.checkIfRecipeIsFavorite()
            let isCreator = await viewModel.checkIfCurrentUserIsCreator()
            
            await MainActor.run {
                self.recipeImageView.configure(
                    with: image,
                    isFavorite: isFavorite,
                    isCreator: isCreator,
                    recipeId: viewModel.recipeId,
                    parentViewController: self,
                    showFavoriteButton: viewModel.isOnline
                )
                loadImageIndicator.stopAnimating()
            }
        }
    }
    
    private func setupMetaStack() {
        let metaStack = UniversalRecipeMetaStackView()
        metaStack.configure(
            with: viewModel.metaData,
            averageRating: viewModel.averageRating,
            recipeId: viewModel.recipeId,
            isOnline: viewModel.isOnline
        )
        metaStack.delegate = self
        stackView.addArrangedSubview(metaStack)
    }

    private func setupDescription() {
        let descriptionLabel = UILabel(
            text: viewModel.description ?? "",
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
            title: viewModel.rateButtonTitle,
            backgroundColor: AppColors.primaryOrange,
            titleColor: .white,
            cornerRadius: Constants.cornerRadiusSmall,
            target: self,
            action: #selector(rateButtonTapped)
        )
        rateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        stackView.addArrangedSubview(rateButton)
    }
    
    // MARK: - Actions
    internal override func navBarRightButtonHandler() {
        guard case .online = recipeSource,
              let recipeDetails = viewModel.recipeDetails,
              let imageData = viewModel.imageData else { return }
        
        let savingIndicator = UIActivityIndicatorView.createIndicator(
            style: .medium,
            centerIn: view
        )
        savingIndicator.startAnimating()
        view.addSubview(savingIndicator)
        
        // Обновляем кнопку сразу
        addNavBarButtons(at: .right, types: [.title(AppStrings.Buttons.delete)])
        
        Task {
            await viewModel.loadInstructionImages()
            
            let success = storageManager.saveRecipe(
                recipeDetails,
                imageData: imageData,
                instructionImages: viewModel.instructionImagesData
            )
            
            await MainActor.run {
                savingIndicator.stopAnimating()
                savingIndicator.removeFromSuperview()
                
                if success {
                    AlertManager.shared.show(
                        on: self,
                        title: AppStrings.Alerts.successTitle,
                        message: "Рецепт сохранен"
                    )
                } else {
                    AlertManager.shared.show(
                        on: self,
                        title: AppStrings.Alerts.errorTitle,
                        message: "Не удалось сохранить рецепт"
                    )
                }
            }
        }
    }
    
    @objc private func rateButtonTapped() {
        guard case .online(let recipeId) = recipeSource else { return }
        let rateVC = RecipeRatingController(recipeId: recipeId)
        navigationController?.pushViewController(rateVC, animated: true)
    }
    
    private func addIngredientToShoppingList(_ ingredient: Ingredient/*IngredientData*/) {
        ShoppingListManager.shared.addIngredient(ingredient)
        AlertManager.shared.show(
            on: self,
            title: "Добавлено",
            message: "\(ingredient.name) добавлен в список покупок"
        )
    }
}

// MARK: - RecipeMetaStackViewDelegate
extension RecipeWatchController: @preconcurrency RecipeMetaStackViewDelegate {
    func didTapRatingView(recipeId: UUID) {
        guard viewModel.isOnline else { return }
        let reviewsVC = ReviewsViewController(recipeId: recipeId, averageRating: viewModel.averageRating)
        navigationController?.pushViewController(reviewsVC, animated: true)
    }
}


