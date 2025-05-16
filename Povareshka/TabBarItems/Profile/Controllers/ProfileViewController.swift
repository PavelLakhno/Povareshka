//
//  ProfileViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 27.08.2024.
//

import UIKit

class ProfileViewController: UIViewController {
    
    // MARK: - UI Components
    private let profileHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 40
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать профиль", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private let menuItems: [[MenuItem]] = [
        [
            MenuItem(title: "Мои рецепты", icon: "book"),
            MenuItem(title: "Избранное", icon: "heart"),
            MenuItem(title: "Список покупок", icon: "cart")
        ],
        [
            MenuItem(title: "Настройки", icon: "gearshape"),
            MenuItem(title: "Помощь", icon: "questionmark.circle"),
            MenuItem(title: "О приложении", icon: "info.circle")
        ],
        [
            MenuItem(title: "Выйти", icon: "rectangle.portrait.and.arrow.right", isDestructive: true)
        ]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        configureUser()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGray6
        title = "Профиль"
        
        view.addSubview(profileHeaderView)
        profileHeaderView.addSubview(profileImageView)
        profileHeaderView.addSubview(nameLabel)
        profileHeaderView.addSubview(emailLabel)
        profileHeaderView.addSubview(editProfileButton)
        view.addSubview(menuTableView)
        
        NSLayoutConstraint.activate([
            profileHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: profileHeaderView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            nameLabel.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            
            editProfileButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 12),
            editProfileButton.centerXAnchor.constraint(equalTo: profileHeaderView.centerXAnchor),
            editProfileButton.bottomAnchor.constraint(equalTo: profileHeaderView.bottomAnchor, constant: -20),
            
            menuTableView.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor),
            menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        menuTableView.register(MenuItemCell.self, forCellReuseIdentifier: "MenuItemCell")
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }
    
    private func configureUser() {
        // Configure with user data
        Task {
            let session = try await SupabaseManager.shared.client.auth.session
            emailLabel.text = session.user.email
        }
        nameLabel.text = "Иван Иванов"
        
    }
}

// MARK: - UITableView Delegate & DataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        let menuItem = menuItems[indexPath.section][indexPath.row]
        cell.configure(with: menuItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = menuItems[indexPath.section][indexPath.row]
        
        switch menuItem.title {
        case "Мои рецепты":
            print("Мои рецепты")
//            let myRecipesVC = RecipesViewController()
//            myRecipesVC.mode = .myRecipes
//            navigationController?.pushViewController(myRecipesVC, animated: true)
            
        case "Избранное":
            print("Избранное")
//            let favoritesVC = FavoritesViewController()
//            navigationController?.pushViewController(favoritesVC, animated: true)
            
        case "Список покупок":
            let shoppingListVC = ShoppingListViewController()
            present(shoppingListVC, animated: true)
//            navigationController?.pushViewController(shoppingListVC, animated: true)
            
        case "Настройки":
            let settingsVC = SettingsViewController()
            present(settingsVC, animated: true)
//            navigationController?.pushViewController(settingsVC, animated: true)
            
        case "Помощь":
            print("Помощь")
//            let helpVC = HelpViewController()
//            navigationController?.pushViewController(helpVC, animated: true)
            
        case "О приложении":
            print("О приложении")
//            let aboutVC = AboutViewController()
//            navigationController?.pushViewController(aboutVC, animated: true)
            
        case "Выйти":
            showLogoutAlert()
        default:
            print("default")
        }
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Выйти",
            message: "Вы уверены, что хотите выйти из аккаунта?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.logout()
        })
        
        present(alert, animated: true)
    }
    
    private func logout() {
        // Clear user data
        UserDefaults.standard.removeObject(forKey: "user_token")
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signOut()
                print("Success")
            } catch {
                print("Fail")
            }
        }
        // Present auth screen
        let authVC = AuthViewController()
        let navController = UINavigationController(rootViewController: authVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}
