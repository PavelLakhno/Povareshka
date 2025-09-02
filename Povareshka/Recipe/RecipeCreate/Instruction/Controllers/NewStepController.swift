//
//  NewStepController.swift
//  Povareshka
//
//  Created by user on 09.06.2025.
//

import UIKit

class NewStepController: BaseController {
    // MARK: - Properties
    private let stepNumber: Int
    private var stepImage: UIImage?
    private var stepDescription: String?
    
    private lazy var stepPhotoPickerView = UIImagePickerController(delegate: self)

    private let customScrollView = UIScrollView(backgroundColor: Resources.Colors.backgroundLight)
    override var scrollView: UIScrollView { customScrollView }
    
    private let contentView = UIView(backgroundColor: Resources.Colors.backgroundLight)
    
    private let imageBubbleView = UIView(backgroundColor: .white, cornerRadius: 12)
    private let stepImageView = UIImageView(
        cornerRadius: 12,
        contentMode: .scaleAspectFit,
        borderWidth: 1
    )
   
    private lazy var addPhotoButton = UIButton(title: Resources.Strings.Buttons.addPhoto,
                                               titleColor: Resources.Colors.orange,
                                               font: .helveticalRegular(withSize: 16),
                                               target: self, action: #selector(addPhotoTapped))
    private lazy var saveButton = UIButton(title: Resources.Strings.Buttons.save,
                                           backgroundColor: Resources.Colors.orange,
                                           titleColor: .white,
                                           font: .helveticalRegular(withSize: 16),
                                           cornerRadius: 10,
                                           target: self, action: #selector(saveButtonTapped))
    
    private lazy var removePhotoIconButton: UIButton = {
        let button = UIButton(
            image: Resources.Images.Icons.trash,
            backgroundColor: .white.withAlphaComponent(0.6),
            tintColor: .gray,
            cornerRadius: 16,
            size: CGSize(width: 32, height: 32),
            target: self,
            action: #selector(removePhotoTapped)
        )
        button.isHidden = true
        return button
    }()
    
    private lazy var descriptionTextView = UITextView.configureTextView(
        placeholder: Resources.Strings.Placeholders.enterDescription,
        delegate: self
    )

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
        setupNavigationBar()
        setupViews()
        setupConstraints()
        configureWithData()
        updateUI()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.title = "Шаг \(stepNumber)"
        addNavBarButtons(at: .left, types: [.title(Resources.Strings.Buttons.cancel)])
    }
    
    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageBubbleView)
        imageBubbleView.addSubview(stepImageView)
        imageBubbleView.addSubview(removePhotoIconButton)
        contentView.addSubview(addPhotoButton)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(saveButton)
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
            
            imageBubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageBubbleView.heightAnchor.constraint(equalTo: imageBubbleView.widthAnchor, multiplier: 0.75),
            
            stepImageView.topAnchor.constraint(equalTo: imageBubbleView.topAnchor),
            stepImageView.leadingAnchor.constraint(equalTo: imageBubbleView.leadingAnchor),
            stepImageView.trailingAnchor.constraint(equalTo: imageBubbleView.trailingAnchor),
            stepImageView.bottomAnchor.constraint(equalTo: imageBubbleView.bottomAnchor),
            
            removePhotoIconButton.topAnchor.constraint(equalTo: imageBubbleView.topAnchor, constant: Constants.paddingSmall),
            removePhotoIconButton.trailingAnchor.constraint(equalTo: imageBubbleView.trailingAnchor, constant: -Constants.paddingSmall),
            
            addPhotoButton.topAnchor.constraint(equalTo: imageBubbleView.bottomAnchor, constant: 10),
            addPhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            descriptionTextView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 20),
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
    
    private func configureWithData() {
        if let description = stepDescription, !description.isEmpty {
            descriptionTextView.text = description
            descriptionTextView.textColor = .black
            descriptionTextView.placeholder = nil
            DispatchQueue.main.async {
                self.descriptionTextView.dynamicTextViewHeight(minHeight: 150)
            }
        } else {
            descriptionTextView.placeholder = Resources.Strings.Placeholders.enterDescription
            descriptionTextView.textColor = .lightGray
        }
        
        if let image = stepImage {
            stepImageView.image = image
            stepImageView.contentMode = .scaleAspectFill
            stepImageView.layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func updateUI() {
        let hasImage = stepImage != nil
        addPhotoButton.setTitle(
            hasImage ?
            Resources.Strings.Buttons.changePhoto : Resources.Strings.Buttons.addPhoto,
            for: .normal
        )
        removePhotoIconButton.isHidden = !hasImage
    }
}

// MARK: - Actions
extension NewStepController {
   
    internal override func navBarLeftButtonHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addPhotoTapped() {
        present(stepPhotoPickerView, animated: true)
    }
    
    @objc private func removePhotoTapped() {
        stepImage = nil
        stepImageView.image = Resources.Images.Icons.cameraMain
        stepImageView.contentMode = .scaleAspectFit
        stepImageView.layer.borderColor = UIColor.black.cgColor
        updateUI()
    }
    
    @objc private func saveButtonTapped() {
        guard let description = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !description.isEmpty else {
            AlertManager.shared.show(
                on: self,
                title: Resources.Strings.Alerts.errorTitle,
                message: Resources.Strings.Alerts.enterDescription
            )
            return
        }
        
        let instruction = Instruction(
            number: stepNumber,
            image: stepImage?.pngData(),
            describe: description
        )
        saveStepCallback?(instruction)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension NewStepController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.clearButtonStatus = !textView.hasText
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        textView.clearButtonStatus = true
        if textView.text.isEmpty {
            textView.text = Resources.Strings.Placeholders.enterDescription
            textView.textColor = .lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.placeholder = textView.hasText ? nil : Resources.Strings.Placeholders.enterDescription
        textView.clearButtonStatus = !textView.hasText
        textView.dynamicTextViewHeight(minHeight: 150)
        scrollView.scrollRectToVisible(textView.frame, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewStepController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let chosenImage = info[.originalImage] as? UIImage else {
            dismiss(animated: true)
            return
        }
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
}

