//
//  RecipeAddController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 06.09.2024.
//

import UIKit
import RealmSwift
import Storage
import Supabase

class NewRecipeController: BaseController {
    // MARK: - Properties
    
    private var isPickerShown = false
    private let dataService = DataService.shared
    
    private var customIndexPathSection: Int = 0
    private var selectedIndexPath: IndexPath?
    private lazy var pickerViewContainer: UIView = UIView()

    private var selectedSettingIndices: [Int] = [0, 0, 0]
    private lazy var pickerView = UIPickerView()
    private var pickerData: [String] = []

    // Data Collections
    private var ingredients: [Ingredient] = []
    private var steps: [Instruction] = []
    private var tags: [String] = []
    private var selectedCategories: [CategorySupabase] = []
    private let tagsManager = TagsManager()
    
    // UI Components
    private let customScrollView = UIScrollView(backgroundColor: Resources.Colors.backgroundLight)
    override var scrollView: UIScrollView { customScrollView }
    private let contentView = UIView(backgroundColor: Resources.Colors.backgroundLight)
    private let contentStackView = UIStackView(
        axis: .vertical,
        alignment: .leading,
        spacing: Constants.spacingBig
    )
    
    private lazy var ingredientsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: MainIngredientsTableViewCell.self, identifier: MainIngredientsTableViewCell.id)
            ],
            delegate: self,
            dataSource: self
        )
        return tableView
    }()
    
    private lazy var settingsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: SettingTableViewCell.self, identifier: SettingTableViewCell.id)
            ],
            delegate: self,
            dataSource: self
        )
        return tableView
    }()
    
    private lazy var stepsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: StepLabelCell.self, identifier: StepLabelCell.id),
                TableViewCellConfig(cellClass: StepPhotoCell.self, identifier: StepPhotoCell.id)
            ],
            delegate: self,
            dataSource: self
        )
        return tableView
    }()
    
    private let imageBubbleView = UIView(
        backgroundColor: .white,
        cornerRadius: Constants.cornerRadiusSmall
    )
    private lazy var recipeImage = UIImageView(
        cornerRadius: Constants.cornerRadiusSmall,
        contentMode: .scaleAspectFit,
        borderWidth: 1
    )
    private lazy var mainPhotoPickerView = UIImagePickerController(delegate: self)
    
    private let ingredientsTitleLabel = UILabel(text: Resources.Strings.Titles.ingredient)
    private let stepsTitleLabel = UILabel(text: Resources.Strings.Titles.cookingStages)
    private let categoryTitleLabel = UILabel(text: Resources.Strings.Titles.categories)
    private let tagsTitleLabel = UILabel(text: Resources.Strings.Titles.tags)
    
    private lazy var recipeNameTextField = UITextField.configureTextField(
        placeholder: Resources.Strings.Placeholders.enterTitle,
        delegate: self
    )
    private lazy var recipeDescriptionTextView = UITextView.configureTextView(
        placeholder: Resources.Strings.Placeholders.enterDescription,
        delegate: self
    )
    
    private lazy var editButton = UIButton(
        image: Resources.Images.Icons.edit,
        backgroundColor: .white,
        tintColor: .black,
        cornerRadius: Constants.cornerRadiusMedium,
        size: Constants.iconCellSizeMedium,
        target: self,
        action: #selector(editButtonTapped)
    )
    
    private lazy var addIngredientButton = UIButton(
        title: Resources.Strings.Buttons.addIngredient,
        backgroundColor: .orange.withAlphaComponent(0.6),
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(addIngredientTapped)
    )
    
    private lazy var addStepButton = UIButton(
        title: Resources.Strings.Buttons.addStep,
        backgroundColor: .orange.withAlphaComponent(0.6),
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(addStepTapped)
    )
    
    private lazy var categoriesCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .verticalFixedSize(Constants.categoryCellSize),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: CategoryGridCell.self, identifier: CategoryGridCell.id),
                CollectionViewCellConfig(cellClass: AddCategoryGridCell.self, identifier: AddCategoryGridCell.id)
            ],
            delegate: self,
            dataSource: self,
            isScrollEnabled: false
        )
        return collectionView
    }()
    
    private lazy var tagsCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .dynamicSize(useLeftAlignedLayout: true, scrollDirection: .vertical),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: TagCollectionViewCell.self, identifier: TagCollectionViewCell.id),
                CollectionViewCellConfig(cellClass: UICollectionViewCell.self, identifier: "AddTagCell")
            ],
            delegate: self,
            dataSource: self,
            isScrollEnabled: false
        )
        return collectionView
    }()
    
    private lazy var loadingIndicator = UIActivityIndicatorView.createIndicator(
        style: .large,
        centerIn: view
    )
    
    private var isSaving = false
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupInitialSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stepsTableView.dynamicHeightForTableView()
        settingsTableView.dynamicHeightForTableView()
    }
    
    // MARK: - Setup Methods
    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = .white
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubviews()
        setupTags()
 
    }
    
    private func setupNavigationBar() {
        navigationItem.title = Resources.Strings.Titles.newRecipe
        addNavBarButtons(at: .left, types: [.title(Resources.Strings.Buttons.cancel)])
        addNavBarButtons(at: .right, types: [.title(Resources.Strings.Buttons.save)])
    }
    
    private func setupTags() {
        tagsManager.onChange = { [weak self] newTags in
            self?.tags = newTags
            self?.tagsCollectionView.reloadData()
            self?.tagsCollectionView.dynamicHeightForCollectionView()
        }
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(imageBubbleView)
        imageBubbleView.addSubview(recipeImage)
        imageBubbleView.addSubview(editButton)
        
        contentStackView.addArrangedSubview(recipeNameTextField)
        contentStackView.addArrangedSubview(recipeDescriptionTextView)
        contentStackView.addArrangedSubview(settingsTableView)
        contentStackView.addArrangedSubview(tagsTitleLabel)
        contentStackView.addArrangedSubview(tagsCollectionView)
        contentStackView.addArrangedSubview(categoryTitleLabel)
        contentStackView.addArrangedSubview(categoriesCollectionView)
        contentStackView.addArrangedSubview(ingredientsTitleLabel)
        contentStackView.addArrangedSubview(ingredientsTableView)
        contentStackView.addArrangedSubview(addIngredientButton)
        contentStackView.addArrangedSubview(stepsTitleLabel)
        contentStackView.addArrangedSubview(stepsTableView)
        contentStackView.addArrangedSubview(addStepButton)
    }
    
    private func setupInitialSettings() {
        selectedSettingIndices = [
            Resources.Settings.SettingType.servings.data.count / 2,
            Resources.Settings.SettingType.cookTime.data.count / 2,
            Resources.Settings.SettingType.difficulty.data.count / 2
        ]
        settingsTableView.reloadData()
        settingsTableView.dynamicHeightForTableView()
    }

    private func setupPicker() {
        pickerViewContainer = UIView(
            frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)
        )
        pickerViewContainer.backgroundColor = Resources.Colors.background
        
        guard let selectedIndexPath = selectedIndexPath,
              let settingType = Resources.Settings.SettingType(rawValue: selectedIndexPath.row)
        else { return }
        
        pickerData = settingType.data
        pickerView.frame = CGRect(x: 0, y: Constants.height, width: view.frame.width, height: 260)
        pickerView.backgroundColor = Resources.Colors.background
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selectedSettingIndices[settingType.rawValue], inComponent: 0, animated: false)
        pickerViewContainer.addSubview(pickerView)
        
        let doneButton = UIButton(
            frame: CGRect(x: 0, y: 0, width: view.frame.width, height:  Constants.height)
        )
        doneButton.setTitle(Resources.Strings.Buttons.done, for: .normal)
        doneButton.setTitleColor(Resources.Colors.orange, for: .normal)
        doneButton.titleLabel?.font = .helveticalRegular(withSize: 16)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        pickerViewContainer.addSubview(doneButton)
        
        view.addSubview(pickerViewContainer)
    }
    
    // MARK: - Helper Methods
    private func showPickerView() {
        isPickerShown = true
        updateSettingsCellsState()
        
        setupPicker()
        UIView.animate(withDuration: 0.3) {
            self.pickerViewContainer.frame.origin.y = self.view.frame.height - 300
        }
    }

    private func hidePickerView() {
        isPickerShown = false
        updateSettingsCellsState()
        
        UIView.animate(withDuration: 0.3) {
            self.pickerViewContainer.frame.origin.y = self.view.frame.height
        }
    }

    private func updateSettingsCellsState() {
        for cell in settingsTableView.visibleCells {
            if let settingCell = cell as? SettingTableViewCell {
                let shouldEnable = !isPickerShown
                settingCell.setActionButtonEnabled(shouldEnable)
            }
        }
    }
    
    private func editStep(at index: Int) {
        let stepToEdit = steps[index]
        let editStepVC = NewStepController(stepNumber: index + 1, existingStep: stepToEdit)
        editStepVC.saveStepCallback = { [weak self] updatedStep in
            guard let self = self else { return }
            let hadImage = self.steps[index].image != nil
            let hasImage = updatedStep.image != nil
            self.steps[index] = updatedStep
            
            if hadImage != hasImage {
                self.stepsTableView.reloadSections([index], with: .automatic)
                DispatchQueue.main.async {
                    self.stepsTableView.dynamicHeightForTableView()
                }
            } else {
                UIView.performWithoutAnimation {
                    self.stepsTableView.reloadSections(IndexSet(integer: index), with: .none)
                    self.stepsTableView.dynamicHeightForTableView()
                }
            }
        }
        navigationController?.pushViewController(editStepVC, animated: true)
    }
    
    private func showDeleteAlert(for section: Int, completion: ((Bool) -> Void)? = nil) {
        AlertManager.shared.showDeleteConfirmation(
            on: self,
            title: Resources.Strings.Alerts.deleteStepTitle,
            message: Resources.Strings.Alerts.deleteStepMessage,
            deleteHandler: { [weak self] in
                guard let self = self else {
                    completion?(false)
                    return
                }
                
                guard self.steps.count > 1 else {
                    AlertManager.shared.show(
                        on: self,
                        title: Resources.Strings.Alerts.errorTitle,
                        message: Resources.Strings.Alerts.minimumStepsError
                    )
                    completion?(false)
                    return
                }
                
                self.steps.remove(at: section)
                UIView.performWithoutAnimation {
                    self.stepsTableView.beginUpdates()
                    self.stepsTableView.deleteSections([section], with: .automatic)
                    self.stepsTableView.endUpdates()
                }
                
                DispatchQueue.main.async {
                    self.stepsTableView.dynamicHeightForTableView()
                    self.renumberSteps()
                }
                
                completion?(true)
            },
            cancelHandler: { completion?(false) }
        )
    }
    
    private func renumberSteps() {
        for (index, _) in steps.enumerated() {
            steps[index].number = index + 1
        }
        stepsTableView.reloadData()
    }
    
    private func getServings() -> Int? {
        Int(Resources.Settings.SettingType.servings
            .data[selectedSettingIndices[Resources.Settings.SettingType.servings.rawValue]])
    }
    
    private func getReadyInMinutes() -> Int? {
        Int(Resources.Settings.SettingType.cookTime
            .data[selectedSettingIndices[Resources.Settings.SettingType.cookTime.rawValue]])
    }
    
    private func getDifficultyLevel() -> Int? {
        Int(Resources.Settings.SettingType.difficulty
            .data[selectedSettingIndices[Resources.Settings.SettingType.difficulty.rawValue]])
    }
}

// MARK: - Action Methods
extension NewRecipeController {
    @objc private func editButtonTapped(_ sender: UIButton) {
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1
            self.present(self.mainPhotoPickerView, animated: true)
        }
    }
    
    @objc private func addIngredientTapped(_ sender: UIButton) {
        let newIngredientVC = NewIngredientViewController()
        newIngredientVC.saveIngredientCallback = { [weak self] newIngredient in
            guard let self = self else { return }
            self.ingredients.append(newIngredient)
            let cellIndex = IndexPath(row: self.ingredients.count - 1, section: 0)
            self.ingredientsTableView.insertRows(at: [cellIndex], with: .automatic)
            DispatchQueue.main.async {
                self.ingredientsTableView.dynamicHeightForTableView()
            }
        }
        navigationController?.pushViewController(newIngredientVC, animated: true)
    }
    
    @objc private func addStepTapped(_ sender: UIButton) {
        let newStepVC = NewStepController(stepNumber: steps.count + 1)
        newStepVC.saveStepCallback = { [weak self] newStep in
            guard let self = self else { return }
            self.steps.append(newStep)
            self.stepsTableView.insertSections([self.steps.count - 1], with: .automatic)
            DispatchQueue.main.async {
                self.stepsTableView.dynamicHeightForTableView()
            }
        }
        navigationController?.pushViewController(newStepVC, animated: true)
    }
    
    @objc private func addCategoriesTapped(_ sender: UIButton) {
        let allCategories = CategorySupabase.allCategories()
        let vc = CategoriesSelectionController(
            allCategories: allCategories,
            selectedCategories: selectedCategories
        )
        vc.completion = { [weak self] categories in
            self?.selectedCategories = categories
            self?.categoriesCollectionView.reloadData()
            self?.categoriesCollectionView.dynamicHeightForCollectionView()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func addTagTapped(_ sender: UIButton) {
        let addTagVC = AddTagViewController()
        addTagVC.originalTags = tagsManager.tags
        addTagVC.saveTagsCallback = { [weak self] tags in
            self?.tagsManager.setTags(tags)
        }
        navigationController?.pushViewController(addTagVC, animated: true)
    }
    
    @objc private func deleteSection(_ sender: UIButton) {
        showDeleteAlert(for: sender.tag)
    }

    @objc private func doneButtonTapped() {
        guard let selectedIndexPath = selectedIndexPath,
              let cell = settingsTableView.cellForRow(at: selectedIndexPath) as? SettingTableViewCell,
              let settingType = Resources.Settings.SettingType(rawValue: selectedIndexPath.row)
        else { return }
        
        
        selectedSettingIndices[settingType.rawValue] = pickerView.selectedRow(inComponent: 0)
        let value = pickerData[selectedSettingIndices[settingType.rawValue]]
        cell.setValueText(settingType.formatValue(value, maxDifficulty: pickerData.count))
        
        cell.setActionButtonEnabled(true)
        hidePickerView()
    }

    internal override func navBarLeftButtonHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    internal override func navBarRightButtonHandler() {
        guard !isSaving else { return }
        
        // Проверяем валидность полей
        guard validateFields() else { return }
        
        isSaving = true
        loadingIndicator.startAnimating()
            
        // Блокируем кнопку сохранения
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        Task {
            do {
                try await dataService.saveRecipe(
                    recipeId: UUID(),
                    title: recipeNameTextField.text ?? "",
                    description: recipeDescriptionTextView.text,
                    image: recipeImage.image,
                    servings: getServings(),
                    readyInMinutes: getReadyInMinutes(),
                    difficulty: getDifficultyLevel(),
                    ingredients: ingredients,
                    steps: steps,
                    tags: tags,
                    categories: selectedCategories
                )
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.isSaving = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.isSaving = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    AlertManager.shared.showError(on: self, error: error)
                }
            }
        }
    }
}

// MARK: - Validation Methods
extension NewRecipeController {
    // MARK: - Validation Methods
    private func validateFields() -> Bool {
        var isValid = true
        var errorMessages: [String] = []
        
        // Проверка главного фото
        if recipeImage.image == nil || recipeImage.image == Resources.Images.Icons.cameraMain {
            isValid = false
            errorMessages.append(Resources.Strings.Alerts.mainPhoto)
            recipeImage.layer.borderColor = UIColor.red.cgColor
        } else {
            recipeImage.layer.borderColor = UIColor.orange.cgColor
        }
        
        // Проверка названия
        if let title = recipeNameTextField.text, title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            isValid = false
            errorMessages.append(Resources.Strings.Alerts.mainTitle)
            recipeNameTextField.layer.borderColor = UIColor.red.cgColor
        } else {
            recipeNameTextField.layer.borderColor = UIColor.orange.cgColor
        }

        
        // Проверка описания
        if recipeDescriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           recipeDescriptionTextView.textColor == UIColor.lightGray {
            isValid = false
            errorMessages.append(Resources.Strings.Alerts.mainDescription)
            recipeDescriptionTextView.layer.borderColor = UIColor.red.cgColor
        } else {
            recipeDescriptionTextView.layer.borderColor = UIColor.orange.cgColor
        }
        
        // Проверка категорий
        if selectedCategories.isEmpty {
            isValid = false
            errorMessages.append(Resources.Strings.Alerts.emptyCategory)
            categoryTitleLabel.textColor = .red
        } else {
            categoryTitleLabel.textColor = .black
        }
        
        // Проверка ингредиентов
        if ingredients.isEmpty {
            isValid = false
            errorMessages.append(Resources.Strings.Alerts.emptyIngredient)
            ingredientsTitleLabel.textColor = .red
        } else {
            ingredientsTitleLabel.textColor = .black
        }
        
        // Проверка шагов
        if steps.isEmpty {
            isValid = false
            errorMessages.append(Resources.Strings.Alerts.emptyStep)
            stepsTitleLabel.textColor = .red
        } else {
            stepsTitleLabel.textColor = .black
        }
        
        // Показываем ошибки, если есть
        if !errorMessages.isEmpty {
            showValidationError(messages: errorMessages)
        }
        
        return isValid
    }

    private func showValidationError(messages: [String]) {
        let errorMessage = messages.joined(separator: "\n• ")
        AlertManager.shared.show(
            on: self,
            title: Resources.Strings.Alerts.emptyData,
            message: "• \(errorMessage)"
        )
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewRecipeController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView == stepsTableView ? steps.count : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        tableView == stepsTableView ? "\(Resources.Strings.Titles.step) \(section + 1)" : nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case stepsTableView:
            let step = steps[section]
            return step.image != nil ? 2 : 1
        case settingsTableView:
            return Resources.Settings.SettingType.allCases.count
        case ingredientsTableView:
            return ingredients.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == stepsTableView {
            let step = steps[indexPath.section]
            
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: StepLabelCell.id,
                    for: indexPath
                ) as? StepLabelCell else {
                    return UITableViewCell()
                }
                cell.configure(with: step.describe)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: StepPhotoCell.id,
                    for: indexPath
                ) as? StepPhotoCell else {
                    return UITableViewCell()
                }
                cell.configure(with: step.image)
                return cell
            }
        } else if tableView == settingsTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingTableViewCell.id,
                for: indexPath
            ) as? SettingTableViewCell,
                  let settingType = Resources.Settings.SettingType(rawValue: indexPath.row)
            else {
                return UITableViewCell()
            }
            let value = settingType.data[selectedSettingIndices[settingType.rawValue]]

            cell.configure(
                with: settingType.title,
                iconName: settingType.iconName ?? UIImage(),
                value: settingType.formatValue(value, maxDifficulty: settingType.data.count),
                indexPath: indexPath
            )
            cell.actionHandler = { [weak self] indexPath in
                guard let self else { return }
                self.selectedIndexPath = indexPath
                self.showPickerView()
            }
            
            // Обновляем состояние кнопки при создании ячейки
            let shouldEnable = !isPickerShown
            cell.setActionButtonEnabled(shouldEnable)

            return cell
        } else if tableView == ingredientsTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MainIngredientsTableViewCell.id,
                for: indexPath
            ) as? MainIngredientsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: ingredients[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == stepsTableView {
            return steps.count > 1
        } else if tableView == ingredientsTableView {
            return ingredients.count > 1
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard tableView == ingredientsTableView else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self, self.ingredients.count > 1 else {
                completion(false)
                return
            }
            
            self.ingredients.remove(at: indexPath.row)
            self.ingredientsTableView.deleteRows(at: [indexPath], with: .none)
            self.ingredientsTableView.dynamicHeightForTableView()
            completion(true)
        }
        deleteAction.image = Resources.Images.Icons.trash
        deleteAction.backgroundColor = .orange.withAlphaComponent(0.3)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableView == stepsTableView else { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = Resources.Colors.backgroundLight
        
        let titleLabel = UILabel(
            text: "\(Resources.Strings.Titles.step) \(section + 1)",
            font: .helveticalBold(withSize: 16),
            textColor: .black
        )
        
        let deleteButton = UIButton(
            image: Resources.Images.Icons.trash,
            tintColor: .orange,
            size: Constants.iconCellSizeMedium,
            target: self,
            action: #selector(deleteSection)
        )
        deleteButton.tag = section
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.paddingMedium),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.paddingMedium),
            deleteButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView == stepsTableView ? 44 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stepsTableView {
            return indexPath.row == 0 ? UITableView.automaticDimension : 200
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stepsTableView {
            return indexPath.row == 0 ? 44 : 200
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == stepsTableView {
            editStep(at: indexPath.section)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewRecipeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let chosenImage = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
        
        if picker == mainPhotoPickerView {
            recipeImage.image = chosenImage
            recipeImage.contentMode = .scaleToFill
            recipeImage.layer.borderColor = UIColor.clear.cgColor
        }
        
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewRecipeController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField != recipeNameTextField {
            ingredients[textField.tag].name = textField.text ?? ""
        }
    }
}

// MARK: - UITextViewDelegate
extension NewRecipeController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == recipeDescriptionTextView && textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == recipeDescriptionTextView {
            textView.clearButtonStatus = !textView.hasText
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == recipeDescriptionTextView {
            textView.resignFirstResponder()
            textView.clearButtonStatus = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == recipeDescriptionTextView {
            textView.placeholder = textView.hasText ? nil : Resources.Strings.Placeholders.enterDescription
            textView.clearButtonStatus = !textView.hasText
            textView.dynamicTextViewHeight(minHeight: Constants.heightStandart)
        }
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension NewRecipeController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let selectedIndexPath = selectedIndexPath,
              let settingType = Resources.Settings.SettingType(rawValue: selectedIndexPath.row)
        else { return nil }
        return settingType.formatValue(pickerData[row], maxDifficulty: pickerData.count)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let selectedIndexPath = selectedIndexPath,
              let cell = settingsTableView.cellForRow(at: selectedIndexPath) as? SettingTableViewCell,
              let settingType = Resources.Settings.SettingType(rawValue: selectedIndexPath.row)
        else { return }

        selectedSettingIndices[settingType.rawValue] = row
        cell.setValueText(settingType.formatValue(pickerData[row], maxDifficulty: pickerData.count))
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension NewRecipeController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == tagsCollectionView ? tagsManager.tags.count + 1 : selectedCategories.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagsCollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTagCell", for: indexPath)
                if cell.contentView.subviews.isEmpty {
                    let label = UILabel()
                    label.text = Resources.Strings.Buttons.addTag
                    label.textColor = .white
                    label.font = .systemFont(ofSize: 14)
                    
                    cell.contentView.addSubview(label)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                    ])
                    
                    cell.backgroundColor = .orange.withAlphaComponent(0.6)
                    cell.layer.cornerRadius = 15
                    cell.clipsToBounds = true
                }
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TagCollectionViewCell.id,
                    for: indexPath
                ) as? TagCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: tagsManager.tags[indexPath.item - 1])
                cell.deleteAction = { [weak self] in
                    self?.tagsManager.removeTag(at: indexPath.item - 1)
                }
                return cell
            }
        } else {
            if indexPath.item == 0 {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: AddCategoryGridCell.id,
                    for: indexPath
                ) as? AddCategoryGridCell else {
                    return UICollectionViewCell()
                }
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CategoryGridCell.id,
                    for: indexPath
                ) as? CategoryGridCell else {
                    return UICollectionViewCell()
                }
                let category = selectedCategories[indexPath.item - 1]
                cell.configure(with: category.title, iconName: category.iconName, isSelected: true)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item == 0 else { return }
        
        if collectionView == tagsCollectionView {
            let addTagVC = AddTagViewController()
            addTagVC.originalTags = tagsManager.tags
            addTagVC.saveTagsCallback = { [weak self] tags in
                self?.tagsManager.setTags(tags)
            }
            navigationController?.pushViewController(addTagVC, animated: true)
        } else {
            let allCategories = CategorySupabase.allCategories()
            let vc = CategoriesSelectionController(
                allCategories: allCategories,
                selectedCategories: selectedCategories
            )
            vc.completion = { [weak self] categories in
                self?.selectedCategories = categories
                self?.categoriesCollectionView.reloadData()
                self?.categoriesCollectionView.dynamicHeightForCollectionView()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == tagsCollectionView {
            if indexPath.item == 0 {
                return CGSize(width: 120, height: 30)
            } else {
                let tag = tagsManager.tags[indexPath.item - 1]
                let font = UIFont.systemFont(ofSize: 14)
                let attributes = [NSAttributedString.Key.font: font]
                let size = (tag as NSString).size(withAttributes: attributes)
                return CGSize(width: size.width + 48, height: 30)
            }
        } else {
            let padding: CGFloat = 16 * 2
            let spacing: CGFloat = 8 * 2
            let availableWidth = collectionView.bounds.width - padding - spacing
            let cellWidth = availableWidth / 3
            return CGSize(width: cellWidth, height: Constants.heightStandart)
        }
    }
}

// MARK: - Constraints
extension NewRecipeController {
    internal override func setupConstraints() {
        setupScrollViewConstraints()
        setupContentViewConstraints()
        setupContentStackViewConstraints()
        setupImageBubbleViewConstraints()
        setupTextFieldAndTextViewConstraints()
        setupTableAndCollectionViewConstraints()
        setupButtonConstraints()
    }
    
    private func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //
    private func setupContentViewConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.paddingMedium),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.paddingMedium),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: contentStackView.heightAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }
    
    private func setupContentStackViewConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func setupImageBubbleViewConstraints() {
        NSLayoutConstraint.activate([
            imageBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageBubbleView.heightAnchor.constraint(equalToConstant: 200),
            
            recipeImage.topAnchor.constraint(equalTo: imageBubbleView.topAnchor),
            recipeImage.leadingAnchor.constraint(equalTo: imageBubbleView.leadingAnchor),
            recipeImage.trailingAnchor.constraint(equalTo: imageBubbleView.trailingAnchor),
            recipeImage.bottomAnchor.constraint(equalTo: imageBubbleView.bottomAnchor),
            
            editButton.topAnchor.constraint(equalTo: imageBubbleView.topAnchor, constant: Constants.paddingSmall),
            editButton.trailingAnchor.constraint(equalTo: imageBubbleView.trailingAnchor, constant: -Constants.paddingSmall)
        ])
    }
    
    private func setupTextFieldAndTextViewConstraints() {
        NSLayoutConstraint.activate([
            recipeNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeNameTextField.heightAnchor.constraint(equalToConstant: Constants.height),
            
            recipeDescriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeDescriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeDescriptionTextView.heightAnchor.constraint(equalToConstant: Constants.heightStandart)
        ])
    }
    
    private func setupTableAndCollectionViewConstraints() {
        NSLayoutConstraint.activate([
            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            settingsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            
            tagsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            tagsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tagsCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            categoryTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            categoriesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoriesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoriesCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.heightStandart),
            
            ingredientsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ingredientsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            ingredientsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ingredientsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ingredientsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            
            stepsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            stepsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stepsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
    }
    
    private func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            addIngredientButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addIngredientButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addIngredientButton.heightAnchor.constraint(equalToConstant: Constants.height),
            
            addStepButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addStepButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addStepButton.heightAnchor.constraint(equalToConstant: Constants.height)
        ])
    }
}
