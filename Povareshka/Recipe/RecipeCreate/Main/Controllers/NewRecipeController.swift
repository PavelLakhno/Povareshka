//
//  RecipeAddController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 06.09.2024.
//

import UIKit

final class NewRecipeController: BaseController {

    // MARK: - Properties
//    private var viewModel: NewRecipeViewModel!
    lazy var viewModel: NewRecipeViewModel = {
        let vm = NewRecipeViewModel()
        return vm
    }()

    // UI Components
    private let customScrollView = UIScrollView(backgroundColor: AppColors.gray100)
    override var scrollView: UIScrollView { customScrollView }
    private let contentView = UIView(backgroundColor: AppColors.gray100)
    
    private let contentStackView = UIStackView(
        axis: .vertical,
        alignment: .leading,
        spacing: Constants.spacingBig
    )
    
    lazy var ingredientsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: MainIngredientsTableViewCell.self, identifier: MainIngredientsTableViewCell.id)
            ],
            delegate: viewModel.ingredientsDataSource,
            dataSource: viewModel.ingredientsDataSource
        )
        return tableView
    }()
    
    lazy var settingsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: SettingTableViewCell.self, identifier: SettingTableViewCell.id)
            ],
            delegate: viewModel.settingsDataSource,
            dataSource: viewModel.settingsDataSource
        )
        return tableView
    }()
    
    lazy var instructionsTableView: UITableView = {
        let tableView = createTableView(
            cellConfigs: [
                TableViewCellConfig(cellClass: StepLabelCell.self, identifier: StepLabelCell.id),
                TableViewCellConfig(cellClass: StepPhotoCell.self, identifier: StepPhotoCell.id)
            ],
            delegate: viewModel.instructionsDataSource,
            dataSource: viewModel.instructionsDataSource
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
    
    private let ingredientsTitleLabel = UILabel(text: AppStrings.Titles.ingredient)
    private let stepsTitleLabel = UILabel(text: AppStrings.Titles.cookingStages)
    private let categoryTitleLabel = UILabel(text: AppStrings.Titles.categories)
    private let tagsTitleLabel = UILabel(text: AppStrings.Titles.tags)
    
    private lazy var recipeNameTextField = UITextField.configureTextField(
        placeholder: AppStrings.Placeholders.enterTitle,
        delegate: self
    )
    private lazy var recipeDescriptionTextView = UITextView.configureTextView(
        placeholder: AppStrings.Placeholders.enterDescription,
        delegate: self
    )
    
    private lazy var editButton = UIButton(
        image: AppImages.Icons.add,
        backgroundColor: .black.withAlphaComponent(0.3),
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusMedium,
        size: Constants.iconCellSizeMedium,
        target: self,
        action: #selector(editButtonTapped)
    )
    
    private lazy var addIngredientButton = UIButton(
        title: AppStrings.Buttons.addIngredient,
        backgroundColor: AppColors.primaryOrange,
        tintColor: .white,
        cornerRadius: Constants.cornerRadiusSmall,
        target: self,
        action: #selector(addIngredientTapped)
    )
    
    private lazy var addStepButton = UIButton(
        title: AppStrings.Buttons.addStep,
        backgroundColor: AppColors.primaryOrange,
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
            delegate: viewModel.categoriesDataSource,
            dataSource: viewModel.categoriesDataSource,
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
            delegate: viewModel.tagsDataSource,
            dataSource: viewModel.tagsDataSource,
            isScrollEnabled: false
        )
        return collectionView
    }()
    
    private lazy var loadingIndicator = UIActivityIndicatorView.createIndicator(
        style: .large,
        centerIn: view
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupDataSources()
    }
    
    // MARK: Navigation
    private func setupNavigationBar() {
        navigationItem.title = AppStrings.Titles.newRecipe
        addNavBarButtons(at: .left, types: [.title(AppStrings.Buttons.cancel)])
        addNavBarButtons(at: .right, types: [.title(AppStrings.Buttons.save)])
    }
    
    internal override func navBarLeftButtonHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    internal override func navBarRightButtonHandler() {
        guard !viewModel.isSaving else { return }

        guard validateFields() else { return }
        
        viewModel.isSaving = true
        loadingIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        Task {
            do {
                try await viewModel.saveRecipe()
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.viewModel.isSaving = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.viewModel.isSaving = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    AlertManager.shared.showError(on: self, error: error)
                }
            }
        }
    }

    // MARK: - Setup Data Source
    private func setupDataSources() {
        viewModel.configurableDataSources.forEach {
            $0.configure(with: self)
        }
    }
    
    // MARK: - Step Management
    func editStep(at index: Int) {
        let stepToEdit = viewModel.instructionsDataSource.steps[index]
        let editStepVC = NewStepController(stepNumber: index + 1, existingStep: stepToEdit)
        editStepVC.saveStepCallback = { [weak self] updatedStep in
            guard let self = self else { return }

            let hadImage = self.viewModel.instructionsDataSource.steps[index].image != nil
            let hasImage = updatedStep.image != nil

            self.viewModel.instructionsDataSource.updateStep(at: index, with: updatedStep)

            if hadImage != hasImage {
                self.instructionsTableView.reloadSections([index], with: .automatic)
                DispatchQueue.main.async {
                    self.instructionsTableView.dynamicHeightForTableView()
                }
            } else {
                UIView.performWithoutAnimation {
                    self.instructionsTableView.reloadSections(IndexSet(integer: index), with: .none)
                    self.instructionsTableView.dynamicHeightForTableView()
                }
            }
        }
        navigationController?.pushViewController(editStepVC, animated: true)
    }

    func handleStepDeletion(at section: Int) {
        guard viewModel.instructionsDataSource.steps.count > 1 else {
            AlertManager.shared.show(
                on: self,
                title: AppStrings.Alerts.errorTitle,
                message: AppStrings.Alerts.minimumStepsError
            )
            return
        }

        AlertManager.shared.showDeleteConfirmation(
            on: self,
            title: AppStrings.Alerts.deleteStepTitle,
            message: AppStrings.Alerts.deleteStepMessage,
            deleteHandler: { [weak self] in
                guard let self = self else { return }

                let success = self.viewModel.instructionsDataSource.removeStep(at: section)
                if success {
                    UIView.performWithoutAnimation {
                        self.instructionsTableView.beginUpdates()
                        self.instructionsTableView.deleteSections([section], with: .automatic)
                        self.instructionsTableView.endUpdates()
                    }

                    DispatchQueue.main.async {
                        self.instructionsTableView.dynamicHeightForTableView()
                        self.viewModel.instructionsDataSource.renumberSteps()
                    }
                }
            },
            cancelHandler: { }
        )
    }

    // MARK: - Picker Management
    func showPickerView(for indexPath: IndexPath, settingType: RecipeSettings.SettingType) {
        viewModel.settingsDataSource.isPickerShown = true
        
        let currentIndex = viewModel.settingsDataSource.getSelectedIndex(for: settingType)
        
        viewModel.pickerManager.showPicker(
            in: self,
            settingType: settingType,
            currentIndex: currentIndex
        ) { [weak self] selectedValue, selectedIndex in
            self?.handlePickerValueSelected(
                selectedValue: selectedValue,
                selectedIndex: selectedIndex,
                indexPath: indexPath,
                settingType: settingType
            )
        }
    }

    private func handlePickerValueSelected(
        selectedValue: String,
        selectedIndex: Int,
        indexPath: IndexPath,
        settingType: RecipeSettings.SettingType
    ) {
        viewModel.settingsDataSource.updateSelectedIndex(selectedIndex, for: settingType)

        if let cell = settingsTableView.cellForRow(at: indexPath) as? SettingTableViewCell {
            cell.setValueText(settingType.formatValue(selectedValue, maxDifficulty: settingType.data.count))
            cell.setActionButtonEnabled(true)
        }
        hidePickerView()
    }

    private func hidePickerView() {
        viewModel.settingsDataSource.isPickerShown = false
        viewModel.pickerManager.hidePicker()
    }

    // MARK: - Setup Methods
    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = .white
        scrollView.contentInsetAdjustmentBehavior = .never
        addSubviews()
        setupTags()
    }
    

    
    private func setupTags() {
        viewModel.tagsManager.onChange = { [weak self] _ in
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
        contentStackView.addArrangedSubview(instructionsTableView)
        contentStackView.addArrangedSubview(addStepButton)
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
            self?.viewModel.ingredientsDataSource.addIngredient(newIngredient)
        }
        navigationController?.pushViewController(newIngredientVC, animated: true)
    }
    
    @objc private func addStepTapped(_ sender: UIButton) {
        let newStepVC = NewStepController(stepNumber: viewModel.instructionsDataSource.steps.count + 1)
        newStepVC.saveStepCallback = { [weak self] newStep in
            self?.viewModel.instructionsDataSource.addStep(newStep)
            self?.instructionsTableView.reloadData() //
            self?.instructionsTableView.dynamicHeightForTableView() //
        }
        navigationController?.pushViewController(newStepVC, animated: true)
    }

    @objc func addTagTapped() {
        let addTagVC = AddTagViewController()
        addTagVC.originalTags = viewModel.tagsManager.tags
        addTagVC.saveTagsCallback = { [weak self] tags in
            self?.viewModel.tagsManager.setTags(tags)
        }
        navigationController?.pushViewController(addTagVC, animated: true)
    }
    
    @objc func addCategoriesTapped() {
        let allCategories = CategorySupabase.allCategories()
        let vc = CategoriesSelectionController(
            allCategories: allCategories,
            selectedCategories: viewModel.categoriesDataSource.selectedCategories
        )
        vc.completion = { [weak self] categories in
            self?.viewModel.categoriesDataSource.selectedCategories = categories
            self?.viewModel.categoriesDataSource.updateSelectedCategories(categories)
            self?.categoriesCollectionView.reloadData()
            self?.categoriesCollectionView.dynamicHeightForCollectionView()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Validation Methods
extension NewRecipeController {
    private func validateFields() -> Bool {
        let validationResult = viewModel.validate()

        updateValidationUI(validationResult.errorMessages)
        
        if !validationResult.errorMessages.isEmpty {
            showValidationError(messages: validationResult.errorMessages)
        }
        
        return validationResult.isValid
    }
    
    private func updateValidationUI(_ errorMessages: [String]) {
        // Default settings
        resetValidationUI()
        
        // Setup errors
        for error in errorMessages {
            switch error {
            case AppStrings.Alerts.mainPhoto:
                recipeImage.layer.borderColor = UIColor.red.cgColor
            case AppStrings.Alerts.mainTitle:
                recipeNameTextField.layer.borderColor = UIColor.red.cgColor
            case AppStrings.Alerts.mainDescription:
                recipeDescriptionTextView.layer.borderColor = UIColor.red.cgColor
            case AppStrings.Alerts.emptyCategory:
                categoryTitleLabel.textColor = .red
            case AppStrings.Alerts.emptyIngredient:
                ingredientsTitleLabel.textColor = .red
            case AppStrings.Alerts.emptyStep:
                stepsTitleLabel.textColor = .red
            default:
                break
            }
        }
    }
    
    private func resetValidationUI() {
        recipeImage.layer.borderColor = AppColors.primaryOrange.cgColor
        recipeNameTextField.layer.borderColor = AppColors.primaryOrange.cgColor
        recipeDescriptionTextView.layer.borderColor = AppColors.primaryOrange.cgColor
        categoryTitleLabel.textColor = .black
        ingredientsTitleLabel.textColor = .black
        stepsTitleLabel.textColor = .black
        tagsTitleLabel.textColor = .black
    }
    
    private func showValidationError(messages: [String]) {
        let errorMessage = messages.joined(separator: "\n• ")
        AlertManager.shared.show(
            on: self,
            title: AppStrings.Alerts.emptyData,
            message: "• \(errorMessage)"
        )
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewRecipeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
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
            viewModel.recipeImage = chosenImage
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
            viewModel.ingredientsDataSource.ingredients[textField.tag].name = textField.text ?? ""
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == recipeNameTextField {
            viewModel.recipeName = textField.text ?? ""
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
            viewModel.recipeDescription = textView.text //
            textView.placeholder = textView.hasText ? nil : AppStrings.Placeholders.enterDescription
            textView.clearButtonStatus = !textView.hasText
            textView.dynamicTextViewHeight(minHeight: Constants.heightStandart)
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
            
            instructionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instructionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            instructionsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
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
