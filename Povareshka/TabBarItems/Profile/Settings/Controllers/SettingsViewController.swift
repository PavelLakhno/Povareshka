//
//  SettingsViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemGray6
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Properties
    private let sections: [SettingsSection] = [
        SettingsSection(title: "Общие", items: [
            SettingsItem(title: "Язык", icon: "globe", type: .navigation("Русский")),
            SettingsItem(title: "Уведомления", icon: "bell", type: .toggle(true)),
            SettingsItem(title: "Темная тема", icon: "moon", type: .toggle(false))
        ]),
        SettingsSection(title: "Приложение", items: [
            SettingsItem(title: "Версия", icon: "info.circle", type: .info("1.0.0")),
            SettingsItem(title: "Очистить кэш", icon: "trash", type: .action),
            SettingsItem(title: "Политика конфиденциальности", icon: "lock", type: .navigation(nil))
        ])
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGray6
        title = "НАСТРОЙКИ"
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableView Delegate & DataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item.title {
        case "Язык":
            print("Язык")
//            let languageVC = LanguageViewController()
//            navigationController?.pushViewController(languageVC, animated: true)
//
        case "Политика конфиденциальности":
            print("Политика конфиденциальности")
//            let privacyVC = PrivacyPolicyViewController()
//            navigationController?.pushViewController(privacyVC, animated: true)
            
        case "Очистить кэш":
            showClearCacheAlert()
        default:
            break
        }
    }
    
    private func showClearCacheAlert() {
        let alert = UIAlertController(
            title: "Очистить кэш",
            message: "Вы уверены, что хотите очистить кэш приложения?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Очистить", style: .destructive) { [weak self] _ in
            self?.clearCache()
        })
        
        present(alert, animated: true)
    }
    
    private func clearCache() {
        // Clear image cache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear temp files
        let fileManager = FileManager.default
        if let tempFolderPath = NSTemporaryDirectory() as String? {
            do {
                let tempFiles = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
                try tempFiles.forEach { file in
                    let tempFilePath = (tempFolderPath as NSString).appendingPathComponent(file)
                    try fileManager.removeItem(atPath: tempFilePath)
                }
                
                // Show success message
                showSuccessAlert()
            } catch {
                print("Error clearing cache: \(error)")
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Готово",
            message: "Кэш успешно очищен",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SettingsCell Delegate
extension SettingsViewController: SettingsCellDelegate {
    func settingsCell(_ cell: SettingsCell, didChangeToggleValue value: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item.title {
        case "Уведомления":
            // Handle notifications toggle
            break
        case "Темная тема":
            // Handle dark mode toggle
            break
        default:
            break
        }
    }
}
