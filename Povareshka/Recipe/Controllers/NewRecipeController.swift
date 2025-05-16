//
//  RecipeAddController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 06.09.2024.
//

import UIKit
import RealmSwift

class NewRecipeController: UIViewController {

    private var customIndexPathSection: Int = 0

    private var indexPath: IndexPath?
    private var selectedIndexPath: IndexPath?
    private lazy var pickerViewContainer = UIView()

    private lazy var servesPicker = UIPickerView()
    private lazy var cookTimePicker = UIPickerView()

    // Collections Data
    private var servesArray: [String] = Resources.Arrayes.createServesArray()
    private var cookTimeArray: [String] = Resources.Arrayes.createCookTimeArray()
    private var ingredients: [Ingredient] = []
    private var steps: [Instruction] = [.init(number: 1, image: nil, describe: nil)]

    private let ingredientsTableView = UITableView()
    private let settingsTableView = UITableView()
    private let stepsTableView = UITableView()

    private let scrollView = UIScrollView(backgroundColor: .neutral10)
    private let contentView = UIView(backgroundColor: .neutral10)
    private let contentStackView = UIStackView(axis: .vertical, aligment: .leading, spacing: 16)

    private let imageBubleView = UIView(backgroundColor: .white, cornerRadius: 12)
    private lazy var recipeImage = UIImageView(image: Resources.Images.Icons.cameraMain,
                                               cornerRadius: 12,
                                               contentMode: .scaleAspectFit, borderWidth: 1)
    private lazy var mainPhotoPickerView = UIImagePickerController(delegate: self)
    private lazy var stepPhotoPickerView = UIImagePickerController(delegate: self)


    private let ingredientsTitleLabel = UILabel.configureTitleLabel(text: Resources.Strings.Tittles.ingredient)
    private let stepsTitleLabel = UILabel.configureTitleLabel(text: Resources.Strings.Tittles.cookingStages)

    private lazy var recipeNameTextField = UITextField.configureTextField(placeholder: Resources.Strings.Placeholders.enterTittle, delegate: self)
    private lazy var recipeDescribeTextView = UITextView.configureTextView(placeholder: Resources.Strings.Placeholders.enterDescription, delegate: self)

    private lazy var editButton = UIButton(image: Resources.Images.Icons.edit,
                                           backgroundColor: .white,
                                           tintColor: .black,
                                           cornerRadius: 16,
                                           size: CGSize(width: 32, height: 32), target: self,
                                           action: #selector(editTaped(_:)))

    private lazy var addNewIngrButton = UIButton(title: Resources.Strings.Buttons.addIngredient,
                                                 image: Resources.Images.Icons.add,
                                                 backgroundColor: .orange.withAlphaComponent(0.6),
                                                 tintColor: .white,
                                                 cornerRadius: 10,
                                                 size: CGSize(width: 25, height: 25), target: self,
                                                 action: #selector(addIngredientTapped(_:)))

    private lazy var addNewStepButton = UIButton(title: Resources.Strings.Buttons.addStep,
                                                 image: Resources.Images.Icons.add,
                                                 backgroundColor: .orange.withAlphaComponent(0.6),
                                                 tintColor: .white,
                                                 cornerRadius: 10,
                                                 size: CGSize(width: 25, height: 25), target: self,
                                                 action: #selector(addStepTapped(_:)))

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addSubviews()
        setupTableViews()
        setupConstraints()
        registerKeyboardNotifications()
    }

    deinit {
        KeyboardManager.removeKeyboardNotifications(observer: self)
    }

    private func setupView() {
        view.backgroundColor = .white
        hideKeyboardWhenTappedAround()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Новый рецепт"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Resources.Strings.Buttons.cancel, style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Resources.Strings.Buttons.save, style: .plain, target: self, action: #selector(saveButtonTapped))
//        navigationItem.leftBarButtonItem?.tintColor = Resources.Colors.orange
//        navigationItem.rightBarButtonItem?.tintColor = Resources.Colors.inactive
    }

    private func registerKeyboardNotifications() {
        KeyboardManager.registerForKeyboardNotifications(observer: self, showSelector: #selector(kbWillShow), hideSelector: #selector(kbWillHide))
    }

    // MARK: - Buttons Methods
    @objc private func editTaped(_ sender: UIButton) {
        sender.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1
            self.present(self.mainPhotoPickerView, animated: true)
        }
    }

    @objc private func addIngredientTapped(_ sender: UIButton) {
        let newIngredientVC = NewIngredientViewController()
        newIngredientVC.saveIngredientCallback = { [unowned self] newIngredient in
            ingredients.append(newIngredient)
            let cellIndex = IndexPath(row: ingredients.count - 1, section: 0)
            ingredientsTableView.insertRows(at: [cellIndex], with: .automatic)
            ingredientsTableView.dynamicHeightForTableView()
        }
        navigationController?.pushViewController(newIngredientVC, animated: true)
    }

    @objc private func addStepTapped(_ sender: UIButton) {
        steps.append(.init(number: steps.count + 1, image: nil, describe: nil))
        let indexSet = IndexSet(integer: steps.count - 1)
        stepsTableView.insertSections(indexSet, with: .automatic)
        stepsTableView.beginUpdates()
        stepsTableView.endUpdates()
        stepsTableView.dynamicHeightForTableView()
    }

    @objc private func addSettingsTapped(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: settingsTableView)
        if let indexPath = settingsTableView.indexPathForRow(at: point) {
            selectedIndexPath = indexPath
            showPickerView()
            if let cell = settingsTableView.cellForRow(at: indexPath) as? SettingTableViewCell {
                cell.actionButton.isEnabled = false
            }
        }
    }

    @objc private func doneButtonTapped() {

        guard let selectedIndexPath = selectedIndexPath,
              let cell = settingsTableView.cellForRow(at: selectedIndexPath) as? SettingTableViewCell else { return }

        switch selectedIndexPath.row {
        case 0:
            cell.valueLabel.text = "\(servesArray[servesPicker.selectedRow(inComponent: 0)]) чел"
        case 1:
            cell.valueLabel.text = "\(cookTimeArray[cookTimePicker.selectedRow(inComponent: 0)]) мин"
        default: break
        }

        cell.actionButton.isEnabled = true
        hidePickerView()
    }


    func showPickerView() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            setupPicker()
            pickerViewContainer.frame.origin.y = view.frame.height - 300
        }
    }

    func hidePickerView() {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            pickerViewContainer.frame.origin.y = view.frame.height
        }
    }

    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func saveButtonTapped() {
        saveNewRecipe()
        navigationController?.popViewController(animated: true)
    }

    private func calculateHeight(_ tableView: UITableView) -> CGFloat {
        tableView.frame = CGRect(x: 0, y: 0,
                                 width: contentStackView.frame.width,
                                 height: CGFloat.greatestFiniteMagnitude)
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }

    // MARK: - Configure UI
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(imageBubleView)
        imageBubleView.addSubview(recipeImage)
        imageBubleView.addSubview(editButton)

        contentStackView.addArrangedSubview(recipeNameTextField)
        contentStackView.addArrangedSubview(recipeDescribeTextView)
        contentStackView.addArrangedSubview(settingsTableView)
        contentStackView.addArrangedSubview(ingredientsTitleLabel)
        contentStackView.addArrangedSubview(ingredientsTableView)
        contentStackView.addArrangedSubview(addNewIngrButton)
        contentStackView.addArrangedSubview(stepsTitleLabel)
        contentStackView.addArrangedSubview(stepsTableView)
        contentStackView.addArrangedSubview(addNewStepButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: contentStackView.heightAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageBubleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageBubleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageBubleView.heightAnchor.constraint(equalToConstant: 200),

            recipeImage.topAnchor.constraint(equalTo: imageBubleView.topAnchor),
            recipeImage.leadingAnchor.constraint(equalTo: imageBubleView.leadingAnchor),
            recipeImage.trailingAnchor.constraint(equalTo: imageBubleView.trailingAnchor),
            recipeImage.bottomAnchor.constraint(equalTo: imageBubleView.bottomAnchor),

            editButton.topAnchor.constraint(equalTo: imageBubleView.topAnchor, constant: 8),
            editButton.trailingAnchor.constraint(equalTo: imageBubleView.trailingAnchor, constant: -8),

            recipeNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeNameTextField.heightAnchor.constraint(equalToConstant: 44),

            recipeDescribeTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeDescribeTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeDescribeTextView.heightAnchor.constraint(equalToConstant: 88),

            settingsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            settingsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            settingsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),

            ingredientsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ingredientsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            ingredientsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ingredientsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ingredientsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: calculateHeight(ingredientsTableView)),

            addNewIngrButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addNewIngrButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addNewIngrButton.heightAnchor.constraint(equalToConstant: 40),

            stepsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            stepsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stepsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: calculateHeight(stepsTableView)),

            addNewStepButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addNewStepButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            addNewStepButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupTableViews() {
        ingredientsTableView.configure(cellClass: MainIngredientsTableViewCell.self, cellIdentifier: MainIngredientsTableViewCell.id, delegate: self, dataSource: self)
        settingsTableView.configure(cellClass: SettingTableViewCell.self, cellIdentifier: SettingTableViewCell.id, delegate: self, dataSource: self)
        stepsTableView.configure(cellClass: StepPhotoCell.self, cellIdentifier: StepPhotoCell.id, delegate: self, dataSource: self)
        stepsTableView.configure(cellClass: StepAddPhotoCell.self, cellIdentifier: StepAddPhotoCell.id, delegate: self, dataSource: self)
        stepsTableView.configure(cellClass: StepDescriptionCell.self, cellIdentifier: StepDescriptionCell.id, delegate: self, dataSource: self)
    }

    private func setupPicker() {
        pickerViewContainer = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300))
        pickerViewContainer.backgroundColor = .white

        if let selectedIndexPath = selectedIndexPath {
            switch selectedIndexPath.row {
            case 0:
                servesPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
                servesPicker.configure(dataSource: self, delegate: self)
                pickerViewContainer.addSubview(servesPicker)
            case 1:
                cookTimePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
                cookTimePicker.configure(dataSource: self, delegate: self)
                pickerViewContainer.addSubview(cookTimePicker)
            default: break
            }
        }

        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        doneButton.setTitle(Resources.Strings.Buttons.done, for: .normal)
        doneButton.setTitleColor(.neutral100, for: .normal)
        doneButton.titleLabel?.font = .helveticalBold(withSize: 16)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        pickerViewContainer.addSubview(doneButton)

        view.addSubview(pickerViewContainer)
    }

    private func saveNewRecipe() {
        let recipeModel = RecipeModel()
        recipeModel.image = recipeImage.image?.pngData()
        recipeModel.title = recipeNameTextField.text ?? ""

        guard let serveCell = settingsTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingTableViewCell,
              let timeCookCell = settingsTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SettingTableViewCell else { return }

        recipeModel.readyInMinutes = serveCell.valueLabel.text ?? ""
        recipeModel.servings = Int(timeCookCell.valueLabel.text ?? "") ?? 0

        for ingredient in ingredients {
            let ingredientModel = IngredientModel()
            ingredientModel.name = ingredient.name
            ingredientModel.amount = ingredient.amount
            recipeModel.ingredients.append(ingredientModel)
        }

        for step in steps {
            let instructionModel = InstructionModel()
            instructionModel.number = step.number
            instructionModel.image = step.image
            instructionModel.describe = step.describe
            recipeModel.instructions.append(instructionModel)
        }

        StorageManager.shared.save(recipeModel)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewRecipeController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == stepsTableView {
            return steps.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == stepsTableView {
            return "Шаг \(section + 1)"
        } else {
            return nil
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case stepsTableView:
            return 2
        case settingsTableView:
            return CreateRecipeSettingDataModel.prebuildData.count
        case ingredientsTableView:
            return ingredients.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == stepsTableView {
            let stepSection = steps[indexPath.section]
            if indexPath.row == 0 {
                let cellDescription = tableView.dequeueReusableCell(withIdentifier: StepDescriptionCell.id, for: indexPath) as! StepDescriptionCell
                self.indexPath = indexPath
                cellDescription.stepDescribeTextView.delegate = self
                cellDescription.stepDescribeTextView.tag = indexPath.section
                cellDescription.textInput = stepSection.describe
                return cellDescription
            } else {
                if stepSection.image == nil {
                    let cellAddPhoto = tableView.dequeueReusableCell(withIdentifier: StepAddPhotoCell.id, for: indexPath) as! StepAddPhotoCell
                    return cellAddPhoto
                } else if stepSection.image != nil {
                    let cellPhoto = tableView.dequeueReusableCell(withIdentifier: StepPhotoCell.id, for: indexPath) as! StepPhotoCell
                    cellPhoto.recipeImage.image = UIImage(data: stepSection.image ?? Data())
                    return cellPhoto
                } else {
                    return UITableViewCell()
                }
            }
        } else if tableView == settingsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.id, for: indexPath) as! SettingTableViewCell
            let currentCell = CreateRecipeSettingDataModel.prebuildData[indexPath.row]
            cell.cellData = currentCell
            cell.actionButton.addTarget(self, action: #selector(addSettingsTapped(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MainIngredientsTableViewCell.id, for: indexPath) as! MainIngredientsTableViewCell
            cell.ingredientName.text = ingredients[indexPath.row].name
            cell.weightName.text = ingredients[indexPath.row].amount + " " + ingredients[indexPath.row].measure
            cell.ingredientName.tag = indexPath.row
            cell.ingredientName.addLeftPadding(padding: 20)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == stepsTableView {
            return steps.count > 1
        } else if tableView == ingredientsTableView {
            return ingredients.count > 1
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] (_, _, completionHandler) in
            if tableView == stepsTableView {
                self.indexPath = indexPath
                if steps.count > 1 {
                    steps.remove(at: indexPath.section)
                    stepsTableView.deleteSections([indexPath.section], with: .none)
                }
            } else {
                if ingredients.count > 1 {
                    ingredients.remove(at: indexPath.row)
                    ingredientsTableView.deleteRows(at: [indexPath], with: .none)
                }
            }
            tableView.beginUpdates()
            DispatchQueue.main.async {
                tableView.reloadData()
            }
            tableView.endUpdates()
            tableView.dynamicHeightForTableView()
            completionHandler(true)
        }
        deleteAction.image = Resources.Images.Icons.trash
        deleteAction.backgroundColor = .orange.withAlphaComponent(0.3)

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stepsTableView {
            let stepSection = steps[indexPath.section]
            if stepSection.image == nil && indexPath.row == 1 {
                return 60
            } else if stepSection.image != nil && indexPath.row == 1 {
                return 200
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stepsTableView {
            let stepSection = steps[indexPath.section]
            if stepSection.image == nil && indexPath.row == 1 {
                return 60
            } else if stepSection.image != nil && indexPath.row == 1 {
                return 200
            } else {
                return 80
            }
        } else {
            return UITableView.automaticDimension
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == stepsTableView {
            if indexPath.row == 1 {
                customIndexPathSection = indexPath.section
                self.indexPath = indexPath
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.present(self.stepPhotoPickerView, animated: true)
                }
            }
        }
    }
}

// MARK: - ImagePickerControllerDelegate
extension NewRecipeController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let choosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if picker == mainPhotoPickerView {
            recipeImage.image = choosenImage
            recipeImage.contentMode = .scaleToFill
            recipeImage.layer.borderColor = UIColor.clear.cgColor
        } else {
            guard let indexPath = self.indexPath else { return }
            steps[indexPath.section].image = choosenImage.pngData()
            stepsTableView.reloadData()
            stepsTableView.dynamicHeightForTableView()
        }
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension NewRecipeController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
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
        if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.clearButtonStatus = !textView.hasText
        if textView == recipeDescribeTextView {
            print("describeTextView")
        } else {
            let cell: StepDescriptionCell = textView.superview?.superview as! StepDescriptionCell
            let tableView: UITableView = cell.superview as! UITableView
            indexPath = tableView.indexPath(for: cell)!
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
        textView.resignFirstResponder()
        textView.clearButtonStatus = true
    }

    func textViewDidChange(_ textView: UITextView) {
        textView.placeholder = textView.hasText ? nil : Resources.Strings.Placeholders.enterDescription
        textView.clearButtonStatus = !textView.hasText
        if textView == recipeDescribeTextView {
            textView.dynamicTextViewHeight(88)
        } else {
            steps[textView.tag].describe = textView.text
            stepsTableView.beginUpdates()
            stepsTableView.endUpdates()
            stepsTableView.dynamicHeightForTableView()
        }
    }
}

// MARK: - Notifications
extension NewRecipeController {
    @objc private func kbWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        if let activeField = view.findFirstResponder() {
            let activeFieldFrame = activeField.convert(activeField.bounds, to: scrollView)
            let visibleFrameHeight = scrollView.frame.height - keyboardHeight
            let offsetY = max(0, activeFieldFrame.maxY - visibleFrameHeight + 50)
            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        }
    }

    @objc private func kbWillHide() {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension NewRecipeController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView == servesPicker ? servesArray.count : cookTimeArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView == servesPicker ? servesArray[row] : cookTimeArray[row]
    }
}
