//
//  RecipeWatchController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 30.03.2025.
//

import UIKit

class RecipeWatchController: UIViewController {
    
    var recipe: RecipeModel?
    
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

        setupTableView(tableView: stepTableView,
                       cellType: InstructionTableViewCell.self,
                       cellIdentifier: InstructionTableViewCell.id)
        
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
        tableView.register(cellType, forCellReuseIdentifier: cellIdentifier)
        stackView.addArrangedSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    //
    private func loadRecipeData() {
        guard let recipe = recipe else { return }
        
        let titleLabel = UILabel()
        titleLabel.text = recipe.title
        titleLabel.font = .helveticalBold(withSize: 24)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        
        if let imageData = recipe.image, let image = UIImage(data: imageData) {
            let imageView = UIImageView(image: image)
            imageView.heightAnchor.constraint(equalToConstant: self.view.frame.width/1.5).isActive = true
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 25
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
        }
        
        let describeLabel = UILabel()
        describeLabel.numberOfLines = 0
        describeLabel.text = recipe.describe
        stackView.addArrangedSubview(describeLabel)

        let readyInMinutesLabel = UILabel()
        readyInMinutesLabel.text = "Время приготовления: \(recipe.readyInMinutes)"
        stackView.addArrangedSubview(readyInMinutesLabel)
        
        let servingsLabel = UILabel()
        servingsLabel.text = "Сервировка: \(recipe.servings) чел"
        stackView.addArrangedSubview(servingsLabel)
        
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = "Ингридиенты:"
        ingredientsLabel.font = .helveticalBold(withSize: 20)
        stackView.addArrangedSubview(ingredientsLabel)
        
        setupTableView(tableView: ingredientTableView,
                       cellType: IngredientTableViewCell.self,
                       cellIdentifier: IngredientTableViewCell.id)
        
        let instructionsLabel = UILabel()
        instructionsLabel.text = "Инструкция:"
        instructionsLabel.font = .helveticalBold(withSize: 20)
        stackView.addArrangedSubview(instructionsLabel)
    }
}

extension RecipeWatchController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ingredientTableView {
            return recipe?.ingredients.count ?? 0
        } else {
            return recipe?.instructions.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.isScrollEnabled = false
        
        if tableView == ingredientTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: IngredientTableViewCell.id, for: indexPath) as! IngredientTableViewCell
            if let ingredient = recipe?.ingredients[indexPath.row] {
//                cell.titleLabel.text = ingredient.name
//                cell.countLabel.text = ingredient.amount
                
                var content = cell.defaultContentConfiguration()
                content.text = "\(ingredient.name) (\(ingredient.amount))"
                cell.contentConfiguration = content

                // Create a custom button with SF Symbols
                let addButton = UIButton(type: .system)
                addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                addButton.tintColor = .systemOrange
                addButton.tag = indexPath.row
                addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)

                // Set fixed frame for the button
                addButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                
//                 Create a container view for the button
//                let buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
//                buttonContainer.addSubview(addButton)
                
//                 Set the container as the accessory view
                cell.accessoryView = addButton
            }
            tableView.beginUpdates()
//            DispatchQueue.main.async {
//                tableView.reloadData()
//            }
            tableView.endUpdates()
            tableView.dynamicHeightForTableView()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: InstructionTableViewCell.id, for: indexPath) as! InstructionTableViewCell
            if let instruction = recipe?.instructions[indexPath.row] {
                cell.configure(with: instruction)
            }
            tableView.beginUpdates()
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            tableView.endUpdates()
            tableView.dynamicHeightForTableView()
            return cell
        }
    }
    
    @objc private func addButtonTapped(_ sender: UIButton) {
        guard let ingredient = recipe?.ingredients[sender.tag] else { return }
        let newIngredient = IngredientData(name: ingredient.name, amount: ingredient.amount)
        ShoppingListManager.shared.addIngredient(newIngredient)
        
        // Update button appearance
        sender.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        sender.tintColor = .systemGreen
        sender.isEnabled = false
        
        // Show feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
    }
}
