//
//  SettingsDataSource.swift
//  Povareshka
//
//  Created by user on 03.10.2025.
//

import UIKit

// MARK: - Settings Data Source
final class SettingsCreateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private var selectedIndices: [Int] = [0, 0, 0]
    var onSettingSelected: ((IndexPath, RecipeSettings.SettingType) -> Void)?
    var isPickerShown: Bool = false
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecipeSettings.SettingType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingTableViewCell.id,
            for: indexPath
        ) as? SettingTableViewCell,
              let settingType = RecipeSettings.SettingType(rawValue: indexPath.row)
        else {
            return UITableViewCell()
        }
        
        let value = settingType.data[selectedIndices[settingType.rawValue]]
        cell.configure(
            with: settingType.title,
            iconName: settingType.iconName ?? UIImage(),
            value: settingType.formatValue(value, maxDifficulty: settingType.data.count),
            indexPath: indexPath
        )
        
        cell.actionHandler = { [weak self] indexPath in
            guard let self = self,
                  let settingType = RecipeSettings.SettingType(rawValue: indexPath.row) else { return }
            self.onSettingSelected?(indexPath, settingType)
        }
        
        cell.setActionButtonEnabled(!isPickerShown)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: - Public Methods
    private func setupInitialSettings() {
        updateSelectedIndex(
            RecipeSettings.SettingType.servings.data.count / 2,
            for: .servings
        )
        updateSelectedIndex(
            RecipeSettings.SettingType.cookTime.data.count / 2,
            for: .cookTime
        )
        updateSelectedIndex(
            RecipeSettings.SettingType.difficulty.data.count / 2,
            for: .difficulty
        )
    }
    
    func updateSelectedIndex(_ index: Int, for settingType: RecipeSettings.SettingType) {
        selectedIndices[settingType.rawValue] = index
    }
    
    func getSelectedValue(for settingType: RecipeSettings.SettingType) -> String {
        return settingType.data[selectedIndices[settingType.rawValue]]
    }
    
    func getSelectedIndex(for settingType: RecipeSettings.SettingType) -> Int {
        return selectedIndices[settingType.rawValue]
    }
    
    func getServings() -> Int? {
        Int(RecipeSettings.SettingType.servings.data[selectedIndices[RecipeSettings.SettingType.servings.rawValue]])
    }
    
    func getReadyInMinutes() -> Int? {
        Int(RecipeSettings.SettingType.cookTime.data[selectedIndices[RecipeSettings.SettingType.cookTime.rawValue]])
    }
    
    func getDifficultyLevel() -> Int? {
        Int(RecipeSettings.SettingType.difficulty.data[selectedIndices[RecipeSettings.SettingType.difficulty.rawValue]])
    }
}

extension SettingsCreateDataSource: @preconcurrency DataSourceConfigurable {
    func configure(with controller: NewRecipeController) {
        onSettingSelected = { [weak controller] indexPath, settingType in
            controller?.showPickerView(for: indexPath, settingType: settingType)
        }
        
        setupInitialSettings()
        controller.settingsTableView.dynamicHeightForTableView()
    }
}
