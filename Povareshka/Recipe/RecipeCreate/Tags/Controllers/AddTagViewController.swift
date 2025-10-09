//
//  AddTagViewController.swift
//  Povareshka
//
//  Created by user on 19.06.2025.
//

import UIKit

final class AddTagViewController: BaseController {
    
    private var newTags: [String] = []
    private let tagTextField = UITextField.configureTextField(placeholder: AppStrings.Placeholders.enterTag)
    
    private lazy var addButton = UIButton(
        title: AppStrings.Buttons.add,
        backgroundColor: AppColors.primaryOrange,
        cornerRadius: Constants.cornerRadiusSmall,
        size: Constants.tagSizeButton,
        target: self, action: #selector(addTagTapped)
    )
    
    private lazy var tagsCollectionView: UICollectionView = {
        let collectionView = createCollectionView(
            type: .dynamicSize(useLeftAlignedLayout: true, scrollDirection: .vertical),
            cellConfigs: [
                CollectionViewCellConfig(cellClass: TagCollectionViewCell.self, identifier: TagCollectionViewCell.id),
            ],
            delegate: self,
            dataSource: self,
            isScrollEnabled: false
        )
        return collectionView
    }()
    
    var originalTags: [String] = []
    
    var saveTagsCallback: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTags = originalTags
        
        setupViews()
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = AppStrings.Titles.addTags
        addNavBarButtons(at: .left, types: [.title(AppStrings.Buttons.cancel)])
        addNavBarButtons(at: .right, types: [.title(AppStrings.Buttons.done)])
    }

    internal override func setupViews() {
        super.setupViews()
        view.backgroundColor = AppColors.gray100

        view.addSubview(tagTextField)
        view.addSubview(addButton)
        view.addSubview(tagsCollectionView)
    }
    
    internal override func setupConstraints() {
        NSLayoutConstraint.activate([
            tagTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.paddingMedium),
            tagTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            tagTextField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10),
            tagTextField.heightAnchor.constraint(equalToConstant: 40),
            
            addButton.centerYAnchor.constraint(equalTo: tagTextField.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
           
            tagsCollectionView.topAnchor.constraint(equalTo: tagTextField.bottomAnchor, constant: Constants.paddingMedium),
            tagsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.paddingMedium),
            tagsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.paddingMedium),
            tagsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.paddingMedium)
        ])
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AddTagViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        newTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.id, for: indexPath) as? TagCollectionViewCell else {
            return TagCollectionViewCell()
        }
        cell.configure(with: newTags[indexPath.item])
        cell.deleteAction = { [weak self] in
            self?.newTags.remove(at: indexPath.item)
            collectionView.reloadData()
        }
        return cell
    }
}


// MARK: - Help Methods
extension AddTagViewController {
    @objc private func addTagTapped() {
        guard let tag = tagTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !tag.isEmpty else {
            AlertManager.shared.show(
                on: self,
                title: AppStrings.Alerts.errorTitle,
                message: AppStrings.Alerts.enterTag
            )
            return
        }
        
        if newTags.contains(tag) {
            AlertManager.shared.show(
                on: self,
                title: AppStrings.Alerts.errorTitle,
                message: AppStrings.Alerts.tagExists
            )
            return
        }
        
        if tag.count > 20 {
            AlertManager.shared.show(
                on: self,
                title: AppStrings.Alerts.errorTitle,
                message: AppStrings.Alerts.tagTooLong
            )
            return
        }
        
        if newTags.count >= 10 {
            AlertManager.shared.show(
                on: self,
                title: AppStrings.Alerts.errorTitle,
                message: AppStrings.Alerts.maxTags
            )
            return
        }
        
        newTags.append(tag)
        tagsCollectionView.reloadData()
        tagTextField.text = ""
        tagTextField.resignFirstResponder()
    }
}

// MARK: - NavBar Methods
extension AddTagViewController {
    internal override func navBarLeftButtonHandler() {
        navigationController?.popViewController(animated: true)
    }
    
    internal override func navBarRightButtonHandler() {
        saveTagsCallback?(newTags)
        navigationController?.popViewController(animated: true)
    }
}
