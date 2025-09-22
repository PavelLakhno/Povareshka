//
//  NewIngredientController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import UIKit

class NewIngredientViewController: BaseController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Properties
    private let data = Resources.Strings.Unit.allValues
    
    private let customScrollView = UIScrollView(backgroundColor: Resources.Colors.backgroundLight)
    override var scrollView: UIScrollView { customScrollView }
    private let contentView = UIView(backgroundColor: Resources.Colors.backgroundLight)
   
    private lazy var titleTextField = UITextField.configureTextField(
        placeholder: Resources.Strings.Placeholders.enterIngredientName,
        delegate: self
    )
    
    private lazy var countTextField = UITextField.configureTextField(
        placeholder: Resources.Strings.Placeholders.enterAmount,
        delegate: self
    )
    
    private lazy var measureTextField = UITextField.configureTextField(
        placeholder: Resources.Strings.Placeholders.enterMeasure,
        delegate: self
    )

    private let pickerView = UIPickerView()
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.backgroundColor = .white
        return toolbar
    }()

    private lazy var saveButton = UIButton(title: Resources.Strings.Buttons.save,
                                           backgroundColor: Resources.Colors.orange,
                                           titleColor: .white,
                                           font: .helveticalRegular(withSize: 16),
                                           cornerRadius: 10,
                                           target: self, action: #selector(saveButtonTapped))
    

    var saveIngredientCallback: ((Ingredient) -> Void)?
    
    // MARK: - Init
    init(existingIngredient: Ingredient? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let ingredient = existingIngredient {
            titleTextField.text = ingredient.name
            countTextField.text = ingredient.amount
            measureTextField.text = ingredient.measure
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupPickerView()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.title = Resources.Strings.Titles.ingredient
        addNavBarButtons(at: .left, types: [.title(Resources.Strings.Buttons.cancel)])
    }
    
    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = Resources.Colors.backgroundLight
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextField)
        contentView.addSubview(countTextField)
        contentView.addSubview(measureTextField)
        contentView.addSubview(saveButton)
        
        measureTextField.inputView = pickerView
        measureTextField.inputAccessoryView = toolbar
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            countTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            countTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            countTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.55),
            countTextField.heightAnchor.constraint(equalToConstant: 50),
            
            measureTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            measureTextField.leadingAnchor.constraint(equalTo: countTextField.trailingAnchor, constant: 10),
            measureTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            measureTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: countTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupPickerView() {
        // Установить начальное значение pickerView для редактирования
        if let measure = measureTextField.text, let index = data.firstIndex(of: measure) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let doneButton = UIBarButtonItem(
            title: Resources.Strings.Buttons.done,
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        doneButton.tintColor = Resources.Colors.orange

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
    }
}

// MARK: - Actions
extension NewIngredientViewController {
    internal override func navBarLeftButtonHandler() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        saveNewIngredient()
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
    }
}

// MARK: - Help Methods
extension NewIngredientViewController {
    private func saveNewIngredient() {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            AlertManager.shared.show(
                on: self,
                title: Resources.Strings.Alerts.errorTitle,
                message: Resources.Strings.Alerts.enterIngredientName
            )
            return
        }
        
        guard let countText = countTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let amount = Double(countText), amount > 0 else {
            AlertManager.shared.show(
                on: self,
                title: Resources.Strings.Alerts.errorTitle,
                message: Resources.Strings.Alerts.enterValidAmount
            )
            return
        }
        
        guard let measure = measureTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !measure.isEmpty else {
            AlertManager.shared.show(
                on: self,
                title: Resources.Strings.Alerts.errorTitle,
                message: Resources.Strings.Alerts.enterMeasure
            )
            return
        }
        
        let newIngredient = Ingredient(name: title, amount: countText, measure: measure)
        saveIngredientCallback?(newIngredient)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewIngredientViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == measureTextField {
            return false
        }
        if textField == countTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.isEmpty {
                return true
            }
            
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            let regex = "^[0-9]+(\(decimalSeparator)[0-9]*)?$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: updatedText)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        measureTextField.text = data[row]
    }
}

