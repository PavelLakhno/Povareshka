//
//  AddTagViewController.swift
//  Povareshka
//
//  Created by user on 19.06.2025.
//

import UIKit

class AddTagViewController: UIViewController {

    private var newTags: [String] = []
    var originalTags: [String] = []
    var saveTagsCallback: (([String]) -> Void)?

    private let tagTextField: UITextField = {
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
            string: "Введите тег",
            attributes: attributes as [NSAttributedString.Key : Any])
        return field
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить", for: .normal)
        button.backgroundColor = .orange.withAlphaComponent(0.6)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private var tagsCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.id)
        return collectionView
    }()
    
    private let doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: nil)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newTags = originalTags
        
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    private func setupViews() {
        view.backgroundColor = .neutral10
        title = "Добавить теги"
        
        navigationItem.rightBarButtonItem = doneButton
        
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self

        view.addSubview(tagTextField)
        view.addSubview(addButton)
        view.addSubview(tagsCollectionView)

    }
    
    private func setupConstraints() {
        tagTextField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tagTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tagTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tagTextField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -10),
            tagTextField.heightAnchor.constraint(equalToConstant: 40),
            
            addButton.centerYAnchor.constraint(equalTo: tagTextField.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.widthAnchor.constraint(equalToConstant: 100),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            
            tagsCollectionView.topAnchor.constraint(equalTo: tagTextField.bottomAnchor, constant: 20),
            tagsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tagsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tagsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addTagTapped), for: .touchUpInside)
        doneButton.target = self
        doneButton.action = #selector(doneTapped)
    }
    
    @objc private func addTagTapped() {
        guard let tag = tagTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !tag.isEmpty else { return }
        
        if !newTags.contains(tag) {
            newTags.append(tag)
            tagsCollectionView.reloadData()
        }
        tagTextField.text = ""
    }
    
    @objc private func doneTapped() {
        saveTagsCallback?(newTags)
        navigationController?.popViewController(animated: true)
    }
}

extension AddTagViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        newTags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.id, for: indexPath) as! TagCollectionViewCell
        cell.configure(with: newTags[indexPath.item])
        cell.deleteAction = { [weak self] in
            self?.newTags.remove(at: indexPath.item)
            collectionView.reloadData()
        }
        return cell
    }

}
