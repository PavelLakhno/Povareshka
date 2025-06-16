//
//  RecipeWatchController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

class RecipeWatchController: UIViewController {
    
//    var recipe: RecipeModel?
    //SB
    var recipeId: UUID? // Будем передавать только ID
    private var recipe: RecipeSupabase?
    private var ingredients: [IngredientSupabase] = []
    private var instructions: [InstructionSupabase] = []
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let ingredientTableView = UITableView()
    private let stepTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupScrollView()
        setupStackView()
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
                
                let (recipeResult, ingredientsResult, instructionsResult) = await (try recipe, try ingredients, try instructions)
                
                DispatchQueue.main.async {
                    self.recipe = recipeResult
                    self.ingredients = ingredientsResult
                    self.instructions = instructionsResult
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
    
    private func updateUI() {
        guard let recipe = recipe else { return }
        
        // Очищаем предыдущие вью
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = recipe.title
        titleLabel.font = .helveticalBold(withSize: 24)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        // Изображение
        if let imagePath = recipe.imagePath {
            let imageView = UIImageView()
            imageView.heightAnchor.constraint(equalToConstant: self.view.frame.width/1.5).isActive = true
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 25
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            
            Task {
                do {
                    let data = try await SupabaseManager.shared.client
                        .storage
                        .from("recipes")
                        .download(path: imagePath)
                    
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                } catch {
                    print("Ошибка загрузки изображения: \(error)")
                }
            }
        }
        
        // Описание
        if let description = recipe.description {
            let describeLabel = UILabel()
            describeLabel.numberOfLines = 0
            describeLabel.text = description
            stackView.addArrangedSubview(describeLabel)
        }
        
        // Время приготовления
        if let time = recipe.readyInMinutes {
            let readyInMinutesLabel = UILabel()
            readyInMinutesLabel.text = "\(Resources.Strings.Tittles.timeCooking) \(time) мин"
            stackView.addArrangedSubview(readyInMinutesLabel)
        }
        
        // Количество порций
        if let servings = recipe.servings {
            let servingsLabel = UILabel()
            servingsLabel.text = "\(Resources.Strings.Tittles.tableSetting) \(servings) чел"
            stackView.addArrangedSubview(servingsLabel)
        }
        
        // Ингредиенты
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = Resources.Strings.Tittles.ingredient
        ingredientsLabel.font = .helveticalBold(withSize: 20)
        stackView.addArrangedSubview(ingredientsLabel)
        
        setupTableView(tableView: ingredientTableView,
                      cellType: IngredientTableViewCell.self,
                      cellIdentifier: IngredientTableViewCell.id)
        
        // Инструкции
        let instructionsLabel = UILabel()
        instructionsLabel.text = Resources.Strings.Tittles.cookingStages
        instructionsLabel.font = .helveticalBold(withSize: 20)
        stackView.addArrangedSubview(instructionsLabel)
        
        setupTableView(tableView: stepTableView,
                      cellType: InstructionTableViewCell.self,
                      cellIdentifier: InstructionTableViewCell.id)

    }
}

extension RecipeWatchController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientTableView {
            return ingredients.count
        } else {
            return instructions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.isScrollEnabled = false
        
        if tableView == ingredientTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: IngredientTableViewCell.id, for: indexPath) as! IngredientTableViewCell
            let ingredient = ingredients[indexPath.row]
            var content = cell.defaultContentConfiguration()
            content.text = "\(ingredient.name) \(ingredient.amount)"
            cell.contentConfiguration = content
            cell.addButton.tag = indexPath.row
            cell.addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
            DispatchQueue.main.async {
                tableView.dynamicHeightForTableView()
            }

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: InstructionTableViewCell.id, for: indexPath) as! InstructionTableViewCell
            let instruction = instructions[indexPath.row]
            cell.configure(with: instruction)

            DispatchQueue.main.async {
                tableView.dynamicHeightForTableView()
            }
            
            return cell
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
