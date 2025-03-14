//
//  RecipeAddController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 06.09.2024.
//

import UIKit

struct CellData{
    var id: String
    var image: UIImage?
    var describe: String?
}

class NewRecipeController: UIViewController {
    
    private var servesArray = [String]()
    private var cookTimeArray = [String]()

    var sectionData:[[CellData]] = [[]]
    var customIndexPathSection: Int = 0
    var indexPath: IndexPath!
    
    var servesPicker = UIPickerView()
    var cookTimePicker = UIPickerView()
    var pickerViewContainer: UIView!
    var selectedIndexPath: IndexPath!
    
    // MARK: - Data
    
    // Collections Data
    var ingredientsArray : [(name: String, quantity: String)] = [
        (name: "Название", quantity: "кол-во" )
    ]
    
    private let scrollView : UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .neutral10
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentView : UIView = {
        let content = UIView()
        content.backgroundColor = .neutral10
        content.translatesAutoresizingMaskIntoConstraints = false
        return content
    }()
    
    private let contentStackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = 16
        stack.backgroundColor = .neutral10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let imageBubleView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var recipeImage : UIImageView = {
        let img = UIImageView()
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: "camera_main")
        img.layer.cornerRadius = 12
        img.layer.borderColor = UIColor.orange.cgColor
        img.layer.borderWidth = 1
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private lazy var editButton : UIButton = {
        let btn = UIButton()
        btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.setImage(Resources.Images.Icons.edit, for: .normal)
        btn.addTarget(self, action: #selector(editTaped(_ :)), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let mainPhotoPickerView : UIImagePickerController = {
        let piker = UIImagePickerController()
        piker.allowsEditing = true
        return piker
    }()
    
    private let stepPhotoPickerView : UIImagePickerController = {
        let piker = UIImagePickerController()
        piker.allowsEditing = true
        return piker
    }()
    
    private lazy var recipeNameTextField : UITextField = {
        let field = UITextField()
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.orange.cgColor
        field.layer.borderWidth = 1
        field.textAlignment = .left
        field.returnKeyType = .done
        field.setLeftPaddingPoints(15)
        field.clearButtonMode = .whileEditing
        field.backgroundColor = .white
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]

        field.attributedPlaceholder = NSAttributedString(
            string: "Введите название",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
   
    private lazy var recipeDescribeTextView : UITextView = {
        let field = UITextView()
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.orange.cgColor
        field.layer.borderWidth = 1
        field.textAlignment = .left
        field.textColor = .lightGray
        field.returnKeyType = .done
        field.isScrollEnabled = false
        field.leftSpace(10)
        field.font = .helveticalRegular(withSize: 16)
        field.placeholder = "Введите описание"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let ingredientsTitleLabel : UILabel = {
        let label = UILabel()
        label.heightAnchor.constraint(equalToConstant: 28).isActive = true
        label.font = .helveticalBold(withSize: 20)
        label.textColor = .gray
        label.textAlignment = .left
        label.text = "Ингредиенты"
        return label
    }()
    
    private let ingredientsTableView : UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addNewIngrButton : UIButton = {
        let btn = UIButton()
        btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btn.backgroundColor = .orange.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 10
        btn.setTitle("Добавить ингредиент", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .helveticalRegular(withSize: 20)
        btn.setImage(UIImage(systemName: "plus.circle")?.imageResized(to: CGSize(width: 25, height: 25)).withTintColor(.white), for: .normal)
        btn.addTarget(self, action: #selector(addIngredientTapped(_:)), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    @objc private func addIngredientTapped(_ sender: UIButton) {
        ingredientsArray.append((name: "Название", quantity: "кол-во" ))
        let cellIndex = IndexPath(row: ingredientsArray.count - 1, section: 0)
        ingredientsTableView.insertRows(at: [cellIndex], with: .automatic)
        ingredientsTableView.dynamicHeightForTableView()
    }
    
    private let settingsTableView : UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let stepsTitleLabel : UILabel = {
        let label = UILabel()
        label.heightAnchor.constraint(equalToConstant: 28).isActive = true
        label.font = .helveticalBold(withSize: 20)
        label.textColor = .gray
        label.textAlignment = .left
        label.text = "Этапы приготовления"
        return label
    }()
    
    private let stepsTableView : UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .neutral10
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addNewStepButton : UIButton = {
        let btn = UIButton()
        btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btn.backgroundColor = .orange.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 10
        btn.setTitle("Добавить шаг", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .helveticalRegular(withSize: 20)
        btn.setImage(UIImage(systemName: "plus.circle")?
            .imageResized(to: CGSize(width: 25, height: 25))
            .withTintColor(.white), for: .normal)
        btn.addTarget(self, action: #selector(addStepTapped(_:)), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    @objc private func addStepTapped(_ sender: UIButton) {

        sectionData.append([CellData(id: StepAddPhotoCell.id),
                            CellData(id: StepDescriptionCell.id)])

        let indexSet = IndexSet(integer: sectionData.count - 1)
        stepsTableView.insertSections(indexSet, with: .automatic)
        stepsTableView.beginUpdates()
        stepsTableView.endUpdates()
        stepsTableView.dynamicHeightForTableView()

    }
    // new
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
    
    @objc func doneButtonTapped() {
        if let selectedIndexPath = selectedIndexPath {
            let cell = settingsTableView.cellForRow(at: selectedIndexPath) as? SettingTableViewCell
            
            switch selectedIndexPath.row {
            case 0:
                cell?.valueLabel.text = servesArray[servesPicker.selectedRow(inComponent: 0)]
            case 1:
                let cookMinutes = Int(cookTimeArray[cookTimePicker.selectedRow(inComponent: 0)]) ?? 1
                cell?.valueLabel.text = "\(cookMinutes)" + " min"
            default: break
            }
            cell?.actionButton.isEnabled = true
            hidePickerView()
        }
    }
    
    func showPickerView() {
        UIView.animate(withDuration: 0.3) {
            self.setupPicker()
            self.pickerViewContainer.frame.origin.y = self.view.frame.height - 300
        }
    }
    
    func hidePickerView() {
        UIView.animate(withDuration: 0.3) {
            self.pickerViewContainer.frame.origin.y = self.view.frame.height
        }
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true)

    }
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        navigationItem.title = "Новый рецепт"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = Resources.Colors.orange
        navigationItem.rightBarButtonItem?.tintColor = Resources.Colors.inactive
        
        hideKeyboardWhenTappedAround()
        
        sectionData = [[CellData(id: StepAddPhotoCell.id),
                        CellData(id: StepDescriptionCell.id)]]
        addSubviews()
        
        setupPhotoPicker()
        setupTextFields()
        setupTextViews()
        setupSettingTableViews()
        setupIngredientTableViews()
        setupStepTableViews()
        setupConstraints()
        registerForKeyBoardNotifications()
        fillServesArray()
        fillCookTimeArray()

    }
    
    deinit {
        removeKeyBoardNotification()
    }
    
    // MARK: - Buttons Methods
    @objc private func editTaped(_ sender: UIButton) {
        sender.alpha = 0.5
  
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1
            self.present(self.mainPhotoPickerView, animated: true)
        }
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
        // Ограничения для scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Ограничения для contentView внутри scrollView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            // Привязка ширины contentView к ширине scrollView
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: contentStackView.heightAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
       
        //Ограничения для вступительной части рецепта
        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),

            imageBubleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageBubleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageBubleView.heightAnchor.constraint(equalToConstant: 200),

            recipeImage.topAnchor.constraint(equalTo: imageBubleView.topAnchor),
            recipeImage.leadingAnchor.constraint(equalTo: imageBubleView.leadingAnchor),
            recipeImage.trailingAnchor.constraint(equalTo: imageBubleView.trailingAnchor),
            recipeImage.bottomAnchor.constraint(equalTo: imageBubleView.bottomAnchor),

            editButton.topAnchor.constraint(equalTo: imageBubleView.topAnchor, constant: 8),
            editButton.trailingAnchor.constraint(equalTo: imageBubleView.trailingAnchor, constant: -8),

            recipeNameTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            recipeNameTextField.heightAnchor.constraint(equalToConstant: 44),

            recipeDescribeTextView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            recipeDescribeTextView.heightAnchor.constraint(equalToConstant: 88),
        ])
            
            
        // Ограничения для таблиц
        NSLayoutConstraint.activate([
            settingsTableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            ingredientsTableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            stepsTableView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            settingsTableView.heightAnchor.constraint(equalToConstant: 140),
            ingredientsTableView.heightAnchor.constraint(equalToConstant: 50),
            stepsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 190),
            
            addNewIngrButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addNewIngrButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            addNewStepButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            addNewStepButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6)
        ])
    }
    
    private func setupPhotoPicker() {
        mainPhotoPickerView.delegate = self
        mainPhotoPickerView.sourceType = .photoLibrary
        
        stepPhotoPickerView.delegate = self
        stepPhotoPickerView.sourceType = .photoLibrary
    }
    
    private func setupTextFields() {
        recipeNameTextField.delegate = self
    }

    private func setupTextViews() {
        recipeDescribeTextView.delegate = self
    }
    
    private func setupIngredientTableViews() {
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        ingredientsTableView.register(CreateIngredientsTableViewCell.self, forCellReuseIdentifier: CreateIngredientsTableViewCell.id)
    }
    
    private func setupSettingTableViews() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.id)
    }
    
    private func setupStepTableViews() {
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        stepsTableView.register(StepPhotoCell.self, forCellReuseIdentifier: StepPhotoCell.id)
        stepsTableView.register(StepAddPhotoCell.self, forCellReuseIdentifier: StepAddPhotoCell.id)
        stepsTableView.register(StepDescriptionCell.self, forCellReuseIdentifier: StepDescriptionCell.id)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewRecipeController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == stepsTableView {
            return sectionData.count
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == stepsTableView {
            return "Шаг \(section + 1)"
        } else { return nil }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case stepsTableView:
            return sectionData[section].count
        case settingsTableView:
            return CreateRecipeSettingDataModel.prebuildData.count
        case ingredientsTableView:
            return ingredientsArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == stepsTableView {
            let cell = sectionData[indexPath.section][indexPath.row]
            
            if cell.id == StepAddPhotoCell.id {
                let cellAddPhoto = tableView.dequeueReusableCell(withIdentifier: cell.id, for: indexPath) as! StepAddPhotoCell
                return cellAddPhoto
            } else if cell.id == StepPhotoCell.id {
                let cellPhoto = tableView.dequeueReusableCell(withIdentifier: cell.id, for: indexPath) as! StepPhotoCell
                cellPhoto.recipeImage.image = cell.image
                return cellPhoto
            } else {
                let cellDescription = tableView.dequeueReusableCell(withIdentifier: cell.id, for: indexPath) as! StepDescriptionCell
                self.indexPath = indexPath
                cellDescription.stepDescribeTextView.delegate = self
                cellDescription.textInput = cell.describe
                
                return cellDescription
            }
        } else if tableView == settingsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.id ,for: indexPath) as! SettingTableViewCell
            let currentCell = CreateRecipeSettingDataModel.prebuildData[indexPath.row]
            cell.cellData = currentCell
            cell.actionButton.addTarget(self, action: #selector(addSettingsTapped(_:)), for: .touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateIngredientsTableViewCell.id, for: indexPath) as! CreateIngredientsTableViewCell
            cell.ingredientName.placeholder = ingredientsArray[indexPath.row].name
            cell.weightName.placeholder = ingredientsArray[indexPath.row].quantity
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == stepsTableView {
            return sectionData.count > 1
        } else if tableView == ingredientsTableView {
            return ingredientsArray.count > 1
        } else { return false }
    }
   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] (_, _, completionHandler) in
            
            if tableView == stepsTableView {
                self.indexPath = indexPath
                let section = sectionData[indexPath.section]
                if section.count > 1 {
                    sectionData[indexPath.section].remove(at: indexPath.row)
                    stepsTableView.deleteRows(at: [indexPath], with: .none)
                } else {
                    sectionData.remove(at: indexPath.section)
                    stepsTableView.deleteSections([indexPath.section], with: .none)
                }
            } else {
                if ingredientsArray.count > 1 {
                    ingredientsArray.remove(at: indexPath.row)
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
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .orange.withAlphaComponent(0.3)

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stepsTableView {
            let cell = sectionData[indexPath.section][indexPath.row]
            
            if cell.id == StepPhotoCell.id  {
                return 200
            } else if cell.id == StepAddPhotoCell.id  {
                return 60
            } else {
                return UITableView.automaticDimension
            }
        } else { return UITableView.automaticDimension }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == stepsTableView {
            let cell = sectionData[indexPath.section][indexPath.row]
            
            if cell.id == StepPhotoCell.id  {
                return 200
            } else if cell.id == StepAddPhotoCell.id  {
                return 60
            } else {
                return 80
            }
        } else { return UITableView.automaticDimension }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == stepsTableView {
            let cell = sectionData[indexPath.section][indexPath.row]
            
            if cell.id != StepDescriptionCell.id {
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
extension NewRecipeController : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let choosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        if picker == mainPhotoPickerView {
            recipeImage.image = choosenImage
            recipeImage.contentMode = .scaleToFill // remake
            recipeImage.layer.borderColor = UIColor.clear.cgColor
        } else {
            guard let indexPath = self.indexPath else { return }
            sectionData[indexPath.section][indexPath.row] = CellData(id: StepPhotoCell.id, image: choosenImage)
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
extension NewRecipeController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate
extension NewRecipeController : UITextViewDelegate {

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
            let tableView: UITableView  = cell.superview as! UITableView
            indexPath = tableView.indexPath(for: cell)!
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
        textView.resignFirstResponder()
        textView.clearButtonStatus = true
    }

    func textViewDidChange(_ textView: UITextView) {

        textView.placeholder = textView.hasText ? nil : "Введите описание"
        textView.clearButtonStatus = !textView.hasText

        if textView == recipeDescribeTextView {
            textView.dynamicTextViewHeight(88)
        } else {
            sectionData[customIndexPathSection][textView.tag].describe = textView.text// Обновляем данные

            // Обновляем высоту ячейки
            stepsTableView.beginUpdates()
            stepsTableView.endUpdates()
            stepsTableView.dynamicHeightForTableView()
        }
    }
}

// MARK: - Notifications
extension NewRecipeController {
    
    private func registerForKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyBoardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func kbWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        // Вычисляем высоту клавиатуры
        let keyboardHeight = keyboardFrame.height
        
        // Устанавливаем нижний отступ на высоту клавиатуры
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight

        // Найдем текущее активное поле
        if let activeField = view.findFirstResponder() {
            // Получаем его положение относительно `scrollView`
            let activeFieldFrame = activeField.convert(activeField.bounds, to: scrollView)
            
            // Прокручиваем `scrollView`, если активное поле находится ниже клавиатуры
            let visibleFrameHeight = scrollView.frame.height - keyboardHeight
            let offsetY = max(0, activeFieldFrame.maxY - visibleFrameHeight + 50) // 50 - отступ сверху

            scrollView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
        }
    }
    
    @objc private func kbWillHide() {
        scrollView.contentInset.bottom = -10
        scrollView.verticalScrollIndicatorInsets.bottom = -10
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func fillServesArray() {
        for i in 1...20 {
            servesArray.append("\(i)")
        }
    }
    
    private func fillCookTimeArray() {
        for i in 1..<20 {
            cookTimeArray.append("\(i)")
        }
        
        for i in stride(from: 20, through: 180, by: 5) {
            cookTimeArray.append("\(i)")
        }
    }

}


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
    
    private func setupPicker() {
        pickerViewContainer = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300))
        pickerViewContainer.backgroundColor = .white
        
        if let selectedIndexPath = selectedIndexPath {
            switch selectedIndexPath.row {
            case 0:
                servesPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
                servesPicker.dataSource = self
                servesPicker.delegate = self
                pickerViewContainer.addSubview(servesPicker)
            case 1:
                cookTimePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 300))
                cookTimePicker.dataSource = self
                cookTimePicker.delegate = self
                pickerViewContainer.addSubview(cookTimePicker)
            default: break
            }
        }
        
        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.neutral100, for: .normal)
        doneButton.titleLabel?.font = .helveticalBold(withSize: 16)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        pickerViewContainer.addSubview(doneButton)
        
        view.addSubview(pickerViewContainer)
    }
}
