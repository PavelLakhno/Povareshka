//
//  ShoppingListViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

import UIKit

//class ShoppingListViewController: UIViewController {
//    
//    // MARK: - UI Components
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.separatorStyle = .none
//        tableView.backgroundColor = .clear
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        return tableView
//    }()
//    
//    private let emptyStateView: UIView = {
//        let view = UIView()
//        view.isHidden = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let emptyStateImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "empty_cart")
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    private let emptyStateLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Ваш список покупок пуст"
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .gray
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    // MARK: - Properties
//    private var shoppingItems: [ShoppingItem] = []
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupTableView()
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        view.backgroundColor = .white
//        title = "СПИСОК ПОКУПОК"
//        
//        view.addSubview(tableView)
//        view.addSubview(emptyStateView)
//        
//        emptyStateView.addSubview(emptyStateImageView)
//        emptyStateView.addSubview(emptyStateLabel)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
//            emptyStateView.heightAnchor.constraint(equalToConstant: 200),
//            
//            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
//            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
//            emptyStateImageView.widthAnchor.constraint(equalToConstant: 100),
//            emptyStateImageView.heightAnchor.constraint(equalToConstant: 100),
//            
//            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
//            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
//            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor)
//        ])
//    }
//    
//    private func setupTableView() {
//        tableView.register(ShoppingItemCell.self, forCellReuseIdentifier: "ShoppingItemCell")
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        updateEmptyState()
//    }
//    
//    private func updateEmptyState() {
//        emptyStateView.isHidden = !shoppingItems.isEmpty
//        tableView.isHidden = shoppingItems.isEmpty
//    }
//}
//
//// MARK: - UITableView Delegate & DataSource
//extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return shoppingItems.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItemCell", for: indexPath) as! ShoppingItemCell
//        cell.configure(with: shoppingItems[indexPath.row])
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//}
