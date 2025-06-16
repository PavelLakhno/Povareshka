//
//  NewStepController.swift
//  Povareshka
//
//  Created by user on 09.06.2025.
//

import UIKit

class NewStepController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    private let stepNumber: Int
    private var stepImage: UIImage?
    private var stepDescription: String?
    
    private lazy var stepPhotoPickerView = UIImagePickerController(delegate: self)
    
    private let scrollView = UIScrollView(backgroundColor: .neutral10)
    private let contentView = UIView(backgroundColor: .neutral10)
    
    private let imageBubleView = UIView(backgroundColor: .white, cornerRadius: 12)
    private let stepImageView = UIImageView(
        image: Resources.Images.Icons.cameraMain,
        cornerRadius: 12,
        contentMode: .scaleAspectFit,
        borderWidth: 1
    )
    
    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить фото", for: .normal)
        button.tintColor = .orange
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Описание шага"
        label.font = .helveticalBold(withSize: 16)
        label.textColor = .neutral100
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .helveticalRegular(withSize: 16)
        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.orange.cgColor
        textView.layer.borderWidth = 1
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Сохранить шаг", for: .normal)
        button.backgroundColor = .orange.withAlphaComponent(0.6)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Callback для сохранения шага
    var saveStepCallback: ((Instruction) -> Void)?
    
    // MARK: - Init
    init(stepNumber: Int, existingStep: Instruction? = nil) {
        self.stepNumber = stepNumber
        super.init(nibName: nil, bundle: nil)
        
        if let existingStep = existingStep {
            self.stepDescription = existingStep.describe
            if let imageData = existingStep.image {
                self.stepImage = UIImage(data: imageData)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
        updateUI()
        registerKeyboardNotifications()
    }

    deinit {
        KeyboardManager.removeKeyboardNotifications(observer: self)
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .white
        title = "Шаг \(stepNumber)"
        
        descriptionTextView.delegate = self
        if stepDescription != nil {
            descriptionTextView.text = stepDescription
            DispatchQueue.main.async {
                self.descriptionTextView.dynamicTextViewHeight(minHeight: 150)
            }
        } else {
            descriptionTextView.placeholder = Resources.Strings.Placeholders.enterDescription
        }

        if let stepImage = stepImage {
            stepImageView.image = stepImage
            stepImageView.contentMode = .scaleAspectFill
            stepImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    private func setupActions() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func updateUI() {
        let hasImage = stepImage != nil
        addPhotoButton.setTitle(hasImage ? "Изменить фото" : "Добавить фото", for: .normal)
    }
    
    // MARK: - Actions
    @objc private func addPhotoTapped() {
        present(stepPhotoPickerView, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let description = descriptionTextView.text, !description.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите описание шага")
            return
        }
        
        let imageData = stepImage?.pngData()
        let instruction = Instruction(number: stepNumber, image: imageData, describe: description)
        saveStepCallback?(instruction)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let chosenImage = info[.originalImage] as? UIImage else { return }
        stepImage = chosenImage
        stepImageView.image = chosenImage
        stepImageView.contentMode = .scaleAspectFill
        stepImageView.layer.borderColor = UIColor.clear.cgColor
        updateUI()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // MARK: - TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.clearButtonStatus = !textView.hasText
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
        textView.resignFirstResponder()
        textView.clearButtonStatus = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.placeholder = textView.hasText ? nil : Resources.Strings.Placeholders.enterDescription
        textView.clearButtonStatus = !textView.hasText
        textView.dynamicTextViewHeight(minHeight: 150)
        
    }

    
    // MARK: - Keyboard Handling
    private func registerKeyboardNotifications() {
        KeyboardManager.registerForKeyboardNotifications(
            observer: self,
            showSelector: #selector(keyboardWillShow),
            hideSelector: #selector(keyboardWillHide))
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
        
        if descriptionTextView.isFirstResponder {
            let textViewFrame = descriptionTextView.convert(descriptionTextView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(textViewFrame, animated: true)
        }
    }
    
    @objc private func keyboardWillHide() {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(imageBubleView)
        imageBubleView.addSubview(stepImageView)
        contentView.addSubview(addPhotoButton)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(saveButton)
        
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

            imageBubleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageBubleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageBubleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageBubleView.heightAnchor.constraint(equalTo: imageBubleView.widthAnchor, multiplier: 0.75),
            
            stepImageView.topAnchor.constraint(equalTo: imageBubleView.topAnchor),
            stepImageView.leadingAnchor.constraint(equalTo: imageBubleView.leadingAnchor),
            stepImageView.trailingAnchor.constraint(equalTo: imageBubleView.trailingAnchor),
            stepImageView.bottomAnchor.constraint(equalTo: imageBubleView.bottomAnchor),
            
            addPhotoButton.topAnchor.constraint(equalTo: imageBubleView.bottomAnchor, constant: 10),
            addPhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
            
            saveButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
