//
//  InstructionsDataSource.swift
//  Povareshka
//
//  Created by user on 01.10.2025.
//

import UIKit

final class InstructionsDataSource: NSObject {
    
    // MARK: - Properties
    var instructions: [InstructionSupabase] = []
    
    // MARK: - Public Methods
    func updateInstructions(_ instructions: [InstructionSupabase]) {
        self.instructions = instructions
    }
   
}

// MARK: - UITableViewDataSource
extension InstructionsDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return instructions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let instruction = instructions[section]
        return instruction.imagePath != nil ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let instruction = instructions[indexPath.section]
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InstructionTextCell.id, for: indexPath) as? InstructionTextCell else {
                return InstructionTextCell()
            }
            cell.configure(stepNumber: instruction.stepNumber, description: instruction.description ?? "")
            
            DispatchQueue.main.async {
                tableView.dynamicHeightForTableView()
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InstructionImageCell.id, for: indexPath) as? InstructionImageCell else {
                return InstructionImageCell()
            }

            if let imagePath = instruction.imagePath {
                cell.configure(with: imagePath)
            }
            
            DispatchQueue.main.async {
                tableView.dynamicHeightForTableView()
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension InstructionsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
