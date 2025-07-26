//
//  NewIngredientController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import UIKit

class NewIngredientViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let titleTextField: UITextField = {
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
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]

        field.attributedPlaceholder = NSAttributedString(
            string: "Название",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    let countTextField: UITextField = {
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
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]

        field.attributedPlaceholder = NSAttributedString(
            string: "Количество",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    let measureTextField: UITextField = {
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
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                          NSAttributedString.Key.font: UIFont.helveticalRegular(withSize: 16)]

        field.attributedPlaceholder = NSAttributedString(
            string: "Мера изм.",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    let pickerView = UIPickerView()
    let toolbar = UIToolbar()

    let data = Resources.Strings.Unit.allValues

    var saveIngredientCallback: ((Ingredient) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .neutral10
        title = "Ингредиент"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = Resources.Colors.orange
//        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
//                                                           target: self, action: nil)

        titleTextField.delegate = self
        countTextField.delegate = self
        measureTextField.delegate = self
        
        view.addSubview(titleTextField)
        view.addSubview(countTextField)
        view.addSubview(measureTextField)

        
        // Настройка UIPickerView
        pickerView.delegate = self
        pickerView.dataSource = self

        // Настройка UIToolbar
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(doneButtonTapped))
        doneButton.tintColor = .lightGray
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton, flexibleSpace], animated: true)

        // Настройка inputView и inputAccessoryView для UITextField
        measureTextField.inputView = pickerView
        measureTextField.inputAccessoryView = toolbar
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            countTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            countTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            countTextField.widthAnchor.constraint(equalToConstant: 200),
            countTextField.heightAnchor.constraint(equalToConstant: 50),
            
            measureTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
            measureTextField.leadingAnchor.constraint(equalTo: countTextField.trailingAnchor, constant: 5),
            measureTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            measureTextField.heightAnchor.constraint(equalToConstant: 50)

        ])
    }
    
    @objc func saveButtonTapped() {
        saveNewIngredient()
        navigationController?.popViewController(animated: true)
    }

    // UITextFieldDelegate method
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         textField != measureTextField 
    }


    // UIPickerViewDelegate and UIPickerViewDataSource methods
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

    // Action for done button
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }

    private func saveNewIngredient() {
        guard let title = titleTextField.text, !title.isEmpty,
              let count = countTextField.text, !count.isEmpty,
              let measure = measureTextField.text, !measure.isEmpty else {
            // Обработка ошибки, если поля пустые
            return
        }
        
        let newIngredient = Ingredient(name: title, amount: count, measure: measure)
        saveIngredientCallback?(newIngredient)
    }
}
