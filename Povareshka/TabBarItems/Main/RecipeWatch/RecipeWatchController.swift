//
//  RecipeWatchController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

class RecipeWatchController: UIViewController {
    
    var recipeId: UUID?
    private var recipe: RecipeSupabase?
    private var ingredients: [IngredientSupabase] = []
    private var instructions: [InstructionSupabase] = []
//    private var tags: [String] = ["Вкуснотищааа", "Сало", "Мясо", "Быстро", "Даженеподумалбы"]

    // new collectionViews
    private var tags: [String] = []
    private var categories: [CategorySupabase] = []
    
    private let recipeImageView = RecipeImageWithFavoriteView()
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let ingredientTableView = UITableView()
    private let stepTableView = UITableView()
    private let tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "AddTagCell")
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    // new added
//    private let categoriesCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.register(CategoryGridCell.self, forCellWithReuseIdentifier: CategoryGridCell.id)
//        cv.showsHorizontalScrollIndicator = false
//        return cv
//    }()
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(CategoryGridCell.self, forCellWithReuseIdentifier: CategoryGridCell.id)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupStackView()
        setupTagsCollectionView()
        setupCategoriesCollectionView()
        loadRecipeData()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTagsCollectionView() {
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        tagsCollectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.id)
        tagsCollectionView.backgroundColor = .clear
    }
    
    
    private func setupCategoriesCollectionView() {
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
//        categoriesCollectionView.register(CategoryGridCell.self, forCellWithReuseIdentifier: CategoryGridCell.id)
        categoriesCollectionView.backgroundColor = .clear
    }

    private func setupTableView<T: UITableViewCell>(tableView: UITableView, cellType: T.Type, cellIdentifier: String) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(cellType, forCellReuseIdentifier: cellIdentifier)
        stackView.addArrangedSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func loadRecipeData() {
        guard let recipeId = recipeId else { return }
        
        Task {
            do {
                async let recipe = loadRecipe(id: recipeId)
                async let ingredients = loadIngredients(recipeId: recipeId)
                async let instructions = loadInstructions(recipeId: recipeId)
                async let tags = loadTags(recipeId: recipeId)
                async let categories = loadCategories(recipeId: recipeId)

                
                let (recipeResult, ingredientsResult, instructionsResult, tagsResult, categoriesResult) =
                await (try recipe, try ingredients, try instructions, try tags, try categories)
                
                DispatchQueue.main.async {
                    self.recipe = recipeResult
                    self.ingredients = ingredientsResult
                    self.instructions = instructionsResult
                    self.tags = tagsResult
                    self.categories = categoriesResult
                    self.updateUI()

                }
            } catch {
                DispatchQueue.main.async {
                    print("Ошибка загрузки рецепта: \(error)")
                }
            }
        }

    }

    private func loadRecipe(id: UUID) async throws -> RecipeSupabase {
        try await SupabaseManager.shared.client
            .from("recipes")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    private func loadIngredients(recipeId: UUID) async throws -> [IngredientSupabase] {
        try await SupabaseManager.shared.client
            .from("ingredients")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("order_index")
            .execute()
            .value
    }

    private func loadInstructions(recipeId: UUID) async throws -> [InstructionSupabase] {
        try await SupabaseManager.shared.client
            .from("instructions")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("step_number")
            .execute()
            .value
    }
    
//    private func loadCurrentUserId() async throws -> UUID? {
//        // Получаем текущую сессию
//        let session = try await SupabaseManager.shared.client.auth.session
//        // Возвращаем ID пользователя, если он есть
//        return UUID(uuidString: session.user.id.uuidString.lowercased())
//    }
    
    private func loadTags(recipeId: UUID) async throws -> [String] {
        let tags: [RecipeTagSupabase] = try await SupabaseManager.shared.client
            .from("recipe_tags")
            .select()
            .eq("recipe_id", value: recipeId)
            .execute()
            .value
        
        return tags.map { $0.tag }
    }
 
    private func loadCategories(recipeId: UUID) async throws -> [CategorySupabase] {
        // 1. Получаем связи рецепта с категориями
        let recipeCategories: [RecipeCategorySupabase] = try await SupabaseManager.shared.client
            .from("recipe_categories")
            .select()
            .eq("recipe_id", value: recipeId)
            .execute()
            .value
        
        // 2. Извлекаем ID категорий и преобразуем в строки
        let categoryId = recipeCategories.map { $0.categoryId }
        
        guard !categoryId.isEmpty else { return [] }
        
        print("Ищем категории с ID:", categoryId)
        
        // 3. Получаем сами категории
        let categories: [CategorySupabase] = try await SupabaseManager.shared.client
            .from("categories")
            .select()
            .in("id", values: categoryId)
            .execute()
            .value

        print("Найдены категории:", categories)
        return categories
    }
    
    private func updateUI() {
        guard let recipe = recipe else { return }
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = recipe.title
        titleLabel.font = .helveticalBold(withSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        // Изображение
        recipeImageView.heightAnchor.constraint(equalToConstant: self.view.frame.width/1.5).isActive = true
        stackView.addArrangedSubview(recipeImageView)
        
        if let imagePath = recipe.imagePath {
            
            Task {
                do {
                    let data = try await SupabaseManager.shared.client
                        .storage
                        .from("recipes")
                        .download(path: imagePath)
                    
                    
                    let image = UIImage(data: data)
                    
                    // Проверяем, является ли текущий пользователь создателем рецепта
                    async let isCreator = self.checkIfCurrentUserIsCreator(recipe: recipe)
                    // Проверяем, находится ли рецепт в избранном
                    async let isFavorite = self.checkIfRecipeIsFavorite(recipeId: recipe.id)
                    let (creator, favorite) = await (try isCreator, isFavorite)
                    DispatchQueue.main.async {
                        self.recipeImageView.configure(
                            with: image,
                            isFavorite: favorite,
                            isCreator: creator
                        )
                        
                        if !creator {
                            self.addRateButton()
                        }
                    }
                } catch {
                    print("Ошибка загрузки изображения: \(error)")
                }
            }
        }

        // Горизонтальный стек для метаданных
        let metaStack = RecipeMetaStackView()
        metaStack.configure(with: recipe)
        stackView.addArrangedSubview(metaStack)
        
        // Описание
        if let description = recipe.description {
            let describeLabel = UILabel()
            describeLabel.numberOfLines = 0
            describeLabel.text = description
            stackView.addArrangedSubview(describeLabel)
        }
       
        if !categories.isEmpty {
            let categoriesLabel = UILabel()
            categoriesLabel.text = "Категории"
            categoriesLabel.font = .helveticalBold(withSize: 18)
            stackView.addArrangedSubview(categoriesLabel)
            
            categoriesCollectionView.reloadData()
            let rows = ceil(Double(categories.count) / 3.0)
            let height = rows * 100 + (rows - 1) * 8 // 100 - высота ячейки, 8 - spacing
            
            categoriesCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true

            stackView.addArrangedSubview(categoriesCollectionView)
        }
        
        // Tags
        if !tags.isEmpty {
            let tagsLabel = UILabel()
            tagsLabel.text = "Теги"
            tagsLabel.font = .helveticalBold(withSize: 18)
            stackView.addArrangedSubview(tagsLabel)
            
            tagsCollectionView.reloadData()
            tagsCollectionView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stackView.addArrangedSubview(tagsCollectionView)
        }
        
        // Ингредиенты
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = Resources.Strings.Tittles.ingredient
        ingredientsLabel.textAlignment = .center
        ingredientsLabel.font = .helveticalBold(withSize: 20)
        stackView.addArrangedSubview(ingredientsLabel)
        
        setupTableView(tableView: ingredientTableView,
                      cellType: IngredientCell.self,
                      cellIdentifier: IngredientCell.id)
        
        // Инструкции
        let instructionsLabel = UILabel()
        instructionsLabel.text = Resources.Strings.Tittles.cookingStages
        instructionsLabel.textAlignment = .center
        instructionsLabel.font = .helveticalBold(withSize: 20)
        stackView.addArrangedSubview(instructionsLabel)
        
        setupTableView(tableView: stepTableView, cellType: InstructionTextCell.self, cellIdentifier: InstructionTextCell.id)
        setupTableView(tableView: stepTableView, cellType: InstructionImageCell.self, cellIdentifier: InstructionImageCell.id)

    }
    
    private func addRateButton() {
        let rateButton = UIButton(type: .system)
        rateButton.backgroundColor = .systemOrange
        rateButton.setTitleColor(.white, for: .normal)
        rateButton.layer.cornerRadius = 8
        rateButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        rateButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        //временная заглушка
        rateButton.setTitle("Оценить рецепт", for: .normal)
        rateButton.addTarget(self, action: #selector(self.rateButtonTapped), for: .touchUpInside)
        // Проверяем, оценивал ли уже пользователь рецепт
//        Task {
//            let hasRating = await checkIfUserHasRating()
//            DispatchQueue.main.async {
//                rateButton.setTitle(hasRating ? "Изменить оценку" : "Оценить рецепт", for: .normal)
//                rateButton.addTarget(self, action: #selector(self.rateButtonTapped), for: .touchUpInside)
//            }
//        }
        
        stackView.addArrangedSubview(rateButton)
    }
    
    private func checkIfUserHasRating() async -> Bool {

        do {
            guard let recipeId = recipeId,
                  let userId = try await SupabaseManager.shared.getCurrentUserId() else {
                return false
            }
            let ratings: [Rating] = try await SupabaseManager.shared.client
                .from("ratings")
                .select()
                .eq("recipe_id", value: recipeId)
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return !ratings.isEmpty
        } catch {
            print("Ошибка проверки оценки: \(error)")
            return false
        }
    }
        

    
    @objc private func rateButtonTapped() {
        let rateVC = RateRecipeController()
        self.navigationController?.pushViewController(rateVC, animated: true)
//        guard let recipe = recipe else { return }
//        
//        // Проверяем текущую оценку пользователя
//        Task {
//            let currentRating = await getCurrentUserRating()
//            let currentComment = await getCurrentUserComment()
//            
//            DispatchQueue.main.async {
//                let rateVC = RateRecipeController()
//                rateVC.recipeId = recipe.id
//                rateVC.currentRating = currentRating
//                rateVC.comment = currentComment
//                self.navigationController?.pushViewController(rateVC, animated: true)
//            }
//        }
    }
    
    private func getCurrentUserRating() async -> Int? {
       
        do {
            guard let recipeId = recipeId,
                  let userId = try await SupabaseManager.shared.getCurrentUserId() else {
                return nil
            }
            let ratings: [Rating] = try await SupabaseManager.shared.client
                .from("ratings")
                .select()
                .eq("recipe_id", value: recipeId)
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return ratings.first?.rating
        } catch {
            print("Ошибка получения оценки: \(error)")
            return nil
        }
    }
    
    private func getCurrentUserComment() async -> String? {
        
        do {
            guard let recipeId = recipeId,
                  let userId = try await SupabaseManager.shared.getCurrentUserId() else {
                return nil
            }
            let ratings: [Rating] = try await SupabaseManager.shared.client
                .from("ratings")
                .select()
                .eq("recipe_id", value: recipeId)
                .eq("user_id", value: userId)
                .execute()
                .value
            
            return ratings.first?.comment
        } catch {
            print("Ошибка получения комментария: \(error)")
            return nil
        }
    }
    
    private func checkIfCurrentUserIsCreator(recipe: RecipeSupabase) async -> Bool {
        do {
            guard let currentUserId = try await SupabaseManager.shared.getCurrentUserId(),
                  let creatorId = UUID(uuidString: recipe.userId.uuidString.lowercased()) else {
                return false
            }
            return currentUserId == creatorId
        } catch {
            print("Ошибка получения текущего пользователя: \(error)")
            return false
        }
    }
    
    
    private func checkIfRecipeIsFavorite(recipeId: UUID) async -> Bool {
        // Здесь реализуйте проверку, находится ли рецепт в избранном
        // Верните true, если рецепт в избранном
        return false // временная заглушка
    }
}

extension RecipeWatchController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == stepTableView {
            return instructions.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientTableView {
            return ingredients.count
        } else {
            let instruction = instructions[section]
            return instruction.imagePath != nil ? 2 : 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.isScrollEnabled = false
        
        if tableView == ingredientTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: IngredientCell.id, for: indexPath) as! IngredientCell
            let ingredient = ingredients[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = "\(ingredient.name)  \(ingredient.amount)"
            cell.contentConfiguration = content
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
            DispatchQueue.main.async {
                tableView.dynamicHeightForTableView()
            }
            return cell
        } else {
            let instruction = instructions[indexPath.section]
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: InstructionTextCell.id, for: indexPath) as! InstructionTextCell
                cell.configure(stepNumber: instruction.stepNumber, description: instruction.description ?? "")
                DispatchQueue.main.async {
                    tableView.dynamicHeightForTableView()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: InstructionImageCell.id, for: indexPath) as! InstructionImageCell
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
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        let ingredient = ingredients[sender.tag]
        let newIngredient = IngredientData(name: ingredient.name, amount: ingredient.amount)
        ShoppingListManager.shared.addIngredient(newIngredient)
        
        sender.setImage(Resources.Images.Icons.okFill, for: .normal)
        sender.isEnabled = false
        
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
}

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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.id, for: indexPath) as! TagCollectionViewCell
            cell.configure(with: tags[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryGridCell.id, for: indexPath) as! CategoryGridCell
            cell.configure(with: categories[indexPath.item].title, iconName: categories[indexPath.item].iconName, isSelected: false)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagsCollectionView {
            let tag = tags[indexPath.item]
            let font = UIFont.systemFont(ofSize: 14)
            let attributes = [NSAttributedString.Key.font: font]
            let size = (tag as NSString).size(withAttributes: attributes)
            return CGSize(width: size.width + 24, height: 30)
        } else {
            // Расчет размера для категорий (3 в ряд)
            let padding: CGFloat = 16 * 2
            let spacing: CGFloat = 8 * 2
            let availableWidth = collectionView.bounds.width - padding - spacing
            let cellWidth = availableWidth / 3
            return CGSize(width: cellWidth, height: 100)
        }
    }
}

