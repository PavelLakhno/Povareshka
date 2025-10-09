//
//  RecipeSettings.swift
//  Povareshka
//
//  Created by user on 24.09.2025.
//

import UIKit

enum RecipeSettings {
    enum Arrays {
        static func createServesArray() -> [String] {
            return Array(1...20).map { "\($0)" }
        }

        static func createCookTimeArray() -> [String] {
            return (Array(1..<20) + stride(from: 20, through: 180, by: 5)).map { "\($0)" }
        }
        
        static func createDifficultyArray() -> [String] {
            return Array(1...5).map { "\($0)" } 
        }
    }
    
    enum SettingType: Int, CaseIterable {
        case servings = 0
        case cookTime = 1
        case difficulty = 2
        
        var title: String {
            switch self {
            case .servings: return AppStrings.Titles.tableSetting
            case .cookTime: return AppStrings.Titles.timeCooking
            case .difficulty: return AppStrings.Titles.difficulty
            }
        }
        
        var iconName: UIImage? {
            switch self {
            case .servings: return AppImages.Icons.persons
            case .cookTime: return AppImages.Icons.clockFill
            case .difficulty: return AppImages.Icons.level
            }
        }
        
        var data: [String] {
            switch self {
            case .servings: return Arrays.createServesArray()
            case .cookTime: return Arrays.createCookTimeArray()
            case .difficulty: return Arrays.createDifficultyArray()
            }
        }
        
        func formatValue(_ value: String, maxDifficulty: Int) -> String {
            switch self {
            case .servings: return "\(value) чел"
            case .cookTime: return "\(value) мин"
            case .difficulty: return "\(value) / \(maxDifficulty)"
            }
        }
    }
}
