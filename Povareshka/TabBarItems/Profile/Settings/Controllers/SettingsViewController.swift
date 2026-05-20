//
//  SettingsViewController.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

import UIKit

class SettingsViewController: BaseController {

    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = AppColors.gray100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Properties
    private let sections: [SettingsSection] = [
        SettingsSection(title: AppStrings.Settings.general, items: [
            SettingsItem(title: AppStrings.Settings.language, icon: AppImages.Icons.globe, type: .navigation(AppStrings.Settings.languageValue)),
            SettingsItem(title: AppStrings.Settings.notifications, icon: AppImages.Icons.bell, type: .toggle(true)),
            SettingsItem(title: AppStrings.Settings.darkTheme, icon: AppImages.Icons.moon, type: .toggle(false))
        ]),
        SettingsSection(title: AppStrings.Settings.application, items: [
            SettingsItem(title: AppStrings.Settings.version, icon: AppImages.Icons.info, type: .info(AppStrings.Settings.versionValue)),
            SettingsItem(title: AppStrings.Settings.clearCache, icon: AppImages.Icons.trash, type: .action),
            SettingsItem(title: AppStrings.Settings.privacyPolicy, icon: AppImages.Icons.lock, type: .navigation(nil))
        ])
    ]

    // MARK: - Setup
    override func setupViews() {
        super.setupViews()
        navigationItem.title = AppStrings.Titles.settings
        view.addSubview(tableView)
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.id)
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.id, for: indexPath) as? SettingsCell else {
            return SettingsCell()
        }
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
        case AppStrings.Settings.language:
            break
        case AppStrings.Settings.privacyPolicy:
            break
        case AppStrings.Settings.clearCache:
            showClearCacheAlert()
        default:
            break
        }
    }

    private func showClearCacheAlert() {
        AlertManager.shared.showConfirmation(
            on: self,
            title: AppStrings.Alerts.clearCacheTitle,
            message: AppStrings.Alerts.clearCacheMessage,
            confirmTitle: AppStrings.Buttons.clear,
            confirmStyle: .destructive,
            confirmHandler: { [weak self] in self?.clearCache() }
        )
    }

    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()

        let fileManager = FileManager.default
        if let tempFolderPath = NSTemporaryDirectory() as String? {
            do {
                let tempFiles = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
                try tempFiles.forEach { file in
                    let tempFilePath = (tempFolderPath as NSString).appendingPathComponent(file)
                    try fileManager.removeItem(atPath: tempFilePath)
                }
                AlertManager.shared.showSuccess(
                    on: self,
                    title: AppStrings.Titles.cacheCleared,
                    message: AppStrings.Messages.cacheCleared
                )
            } catch {}
        }
    }
}

// MARK: - SettingsCell Delegate
extension SettingsViewController: @preconcurrency SettingsCellDelegate {
    func settingsCell(_ cell: SettingsCell, didChangeToggleValue value: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let item = sections[indexPath.section].items[indexPath.row]
        
        switch item.title {
        case AppStrings.Settings.notifications:
            break
        case AppStrings.Settings.darkTheme:
            break
        default:
            break
        }
    }
}
