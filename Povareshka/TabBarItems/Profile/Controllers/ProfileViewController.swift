//
//  ProfileViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 27.08.2024.
//

import UIKit
import Storage

class ProfileViewController: BaseController {
    private let dataService = DataService.shared
    // MARK: - UI Components

    private let profileHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView = UIImageView(image: AppImages.Icons.profile,
                                            cornerRadius: 40,
                                            contentMode: .scaleAspectFill,
                                            tintColor: AppColors.gray600,
                                            backgroundColor: AppColors.gray100)

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
    
    private lazy var editProfileButton = UIButton(title: AppStrings.Profile.editProfile,
                                                  titleColor: AppColors.primaryOrange,
                                                  target: self,
                                                  action: #selector(editProfileTapped))
 
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
            MenuItem(title: AppStrings.Profile.myRecipes, icon: AppImages.Icons.book),
            MenuItem(title: AppStrings.Profile.favorites, icon: AppImages.Icons.heartOutline),
            MenuItem(title: AppStrings.Profile.saved, icon: AppImages.Icons.saved)
        ],
        [
            MenuItem(title: AppStrings.Profile.settings, icon: AppImages.Icons.gear),
            MenuItem(title: AppStrings.Profile.help, icon: AppImages.Icons.helpCircle),
            MenuItem(title: AppStrings.Profile.about, icon: AppImages.Icons.info)
        ],
        [
            MenuItem(title: AppStrings.Profile.logout, icon: AppImages.Icons.signOut, isDestructive: true)
        ]
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupTableView()
        configureUser()
    }
    
    // MARK: - Setup
    internal override func setupViews() {
        view.backgroundColor = AppColors.gray100
        navigationItem.title = AppStrings.Titles.profile
        
        view.addSubview(profileHeaderView)
        profileHeaderView.addSubview(profileImageView)
        profileHeaderView.addSubview(nameLabel)
        profileHeaderView.addSubview(emailLabel)
        profileHeaderView.addSubview(editProfileButton)
        view.addSubview(menuTableView)
   
    }
    
    internal override func setupConstraints() {
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
        menuTableView.register(MenuItemCell.self, forCellReuseIdentifier: MenuItemCell.id)
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }
    
    @objc private func editProfileTapped() {
        let editProfileVC = EditProfileController()
        editProfileVC.onProfileUpdated = { [weak self] in
            self?.configureUser() // Обновляем данные после редактирования
        }
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    @objc private func handleImageTap() {
        editProfileTapped() // Перенаправляем на экран редактирования
    }
    
    private func configureUser() {
        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.session
                let profile = try await dataService.fetchUserProfile(userId: session.user.id)
                
                DispatchQueue.main.async {
                    self.updateUI(with: session.user.email ?? "Email", profile: profile)
                }
            } catch {}
        }
    }
    
  
    private func updateUI(with email: String, profile: UserProfile) {
        emailLabel.text = email
        nameLabel.text = profile.username ?? AppStrings.Profile.user
        
        if let avatarURL = profile.avatarURL {
            Task {
                try await loadImage(from: avatarURL)
            }
        }
    }
   
    private func loadImage(from path: String) async throws {
        let data = try await SupabaseManager.shared.client.storage.from("avatars").download(path: path)
        DispatchQueue.main.async {
            self.profileImageView.image = UIImage(data: data)
        }
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemCell.id, for: indexPath) as? MenuItemCell else {
            return MenuItemCell()
        }
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
        case AppStrings.Profile.myRecipes:
            navigationController?.pushViewController(RecipeListController(source: .myRecipes), animated: true)
        case AppStrings.Profile.favorites:
            navigationController?.pushViewController(RecipeListController(source: .favorites), animated: true)
        case AppStrings.Profile.saved:
            navigationController?.pushViewController(SavedRecipesController(), animated: true)
        case AppStrings.Profile.settings:
            navigationController?.pushViewController(SettingsViewController(), animated: true)
        case AppStrings.Profile.help:
            navigationController?.pushViewController(HelpViewController(), animated: true)
        case AppStrings.Profile.about:
            navigationController?.pushViewController(AboutViewController(), animated: true)
        case AppStrings.Profile.logout:
            AlertManager.shared.showConfirmation(
                on: self,
                title: AppStrings.Alerts.logoutTitle,
                message: AppStrings.Alerts.logoutMessage,
                confirmTitle: AppStrings.Buttons.logout,
                confirmStyle: .destructive,
                confirmHandler: { [weak self] in self?.logout() }
            )
        default:
            break
        }
    }
    
    private func logout() {
        UserDefaults.standard.removeObject(forKey: "user_token")
        Task {
            do {
                try await SupabaseManager.shared.client.auth.signOut()
                // Уведомляем координатор о необходимости переключиться на Auth Flow
                NotificationCenter.default.post(name: .userDidLogout, object: nil)
            } catch {}
        }
    }
    
}
