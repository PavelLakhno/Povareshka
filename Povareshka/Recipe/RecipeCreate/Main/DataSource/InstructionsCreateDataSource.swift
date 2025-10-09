//
//  InstructionCreateDataSource.swift
//  Povareshka
//
//  Created by user on 01.10.2025.
//

import UIKit

// MARK: - Steps Data Source для создания рецепта
final class InstructionsCreateDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    var steps: [Instruction] = []
    var onStepsChanged: (([Instruction]) -> Void)?
    var onStepDeleted: ((Int) -> Void)?
    var onStepSelected: ((Int) -> Void)?
    var onStepEditRequested: ((Int) -> Void)?
    
    // MARK: - Public Methods
    func updateSteps(_ steps: [Instruction]) {
        self.steps = steps
    }
    
    func addStep(_ step: Instruction) {
        steps.append(step)
        onStepsChanged?(steps)
    }
    
    func updateStep(at index: Int, with step: Instruction) {
        guard index < steps.count else { return }
        steps[index] = step
        onStepsChanged?(steps)
    }
    
    func removeStep(at index: Int) -> Bool {
        guard steps.count > 1 else { return false }
        steps.remove(at: index)
//        onStepsChanged?(steps)
        return true
    }
    
    func renumberSteps() {
        for (index, _) in steps.enumerated() {
            steps[index].number = index + 1
        }
        onStepsChanged?(steps)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let step = steps[section]
        return step.image != nil ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let step = steps[indexPath.section]
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StepLabelCell.id,
                for: indexPath
            ) as? StepLabelCell else {
                return UITableViewCell()
            }
            cell.configure(with: step.describe)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StepPhotoCell.id,
                for: indexPath
            ) as? StepPhotoCell else {
                return UITableViewCell()
            }
            cell.configure(with: step.image)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(AppStrings.Titles.step) \(section + 1)"
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = AppColors.gray100
        
        let titleLabel = UILabel(
            text: "\(AppStrings.Titles.step) \(section + 1)",
            font: .helveticalBold(withSize: 16),
            textColor: .black
        )
        
        let deleteButton = UIButton(
            image: AppImages.Icons.trash,
            tintColor: AppColors.primaryOrange,
            size: Constants.iconCellSizeMedium,
            target: self,
            action: #selector(deleteButtonTapped(_:))
        )
        deleteButton.tag = section
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.paddingMedium),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.paddingMedium),
            deleteButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? UITableView.automaticDimension : 200
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 44 : 200
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        onStepEditRequested?(indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return steps.count > 1
    }
    
    // MARK: - Actions
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let section = sender.tag
        onStepDeleted?(section)
    }
}

// MARK: - Instructions DataSource
extension InstructionsCreateDataSource: @preconcurrency DataSourceConfigurable {
    func configure(with controller: NewRecipeController) {
        onStepsChanged = { [weak controller] steps in
            controller?.instructionsTableView.reloadData()
            controller?.instructionsTableView.dynamicHeightForTableView()
        }

        onStepDeleted = { [weak controller] section in
            controller?.handleStepDeletion(at: section)
        }

        onStepEditRequested = { [weak controller] section in
            controller?.editStep(at: section)
        }
    }
}
