//
//  NewRecipeViewModel.swift
//  Povareshka
//
//  Created by user on 07.10.2025.
//

import UIKit

@MainActor
final class NewRecipeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recipeName: String = ""
    @Published var recipeDescription: String = ""
    @Published var recipeImage: UIImage?
    @Published var isSaving: Bool = false
    
    // MARK: - Data Sources
    let ingredientsDataSource: IngredientsCreateDataSource
    let instructionsDataSource: InstructionsCreateDataSource
    let settingsDataSource: SettingsCreateDataSource
    let categoriesDataSource: CategoriesCreateDataSource
    let tagsManager: TagsManager
    let tagsDataSource: TagsCreateDataSource
    let pickerManager: SettingsPickerManager
    
    // MARK: - Services
    private let dataService: DataService
    
    // MARK: - Init
    init(dataService: DataService = .shared) {
        self.dataService = dataService
        self.ingredientsDataSource = IngredientsCreateDataSource()
        self.instructionsDataSource = InstructionsCreateDataSource()
        self.settingsDataSource = SettingsCreateDataSource()
        self.categoriesDataSource = CategoriesCreateDataSource()
        self.tagsManager = TagsManager()
        self.tagsDataSource = TagsCreateDataSource(tagsManager: tagsManager)
        self.pickerManager = SettingsPickerManager() 
    }
    
    // MARK: - Validation
    var isValid: Bool {
        !recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !recipeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        recipeImage != nil &&
        !ingredientsDataSource.ingredients.isEmpty &&
        !instructionsDataSource.steps.isEmpty &&
        !categoriesDataSource.selectedCategories.isEmpty 
    }
    
    var configurableDataSources: [DataSourceConfigurable] {
        return [
            ingredientsDataSource,
            instructionsDataSource,
            settingsDataSource,
            tagsDataSource,
            categoriesDataSource
        ]
    }
}

// MARK: - Business Logic
extension NewRecipeViewModel {
    
    // MARK: - Save Recipe
    func saveRecipe() async throws {
        guard !isSaving else { return }
        
        isSaving = true
        defer { isSaving = false }
        
        try await dataService.saveRecipe(
            recipeId: UUID(),
            title: recipeName,
            description: recipeDescription,
            image: recipeImage,
            servings: settingsDataSource.getServings(),
            readyInMinutes: settingsDataSource.getReadyInMinutes(),
            difficulty: settingsDataSource.getDifficultyLevel(),
            ingredients: ingredientsDataSource.ingredients,
            steps: instructionsDataSource.steps,
            tags: tagsManager.tags,
            categories: categoriesDataSource.selectedCategories
        )
    }
    
    // MARK: - Validation
    struct ValidationResult {
        let isValid: Bool
        let errorMessages: [String]
    }
    
    func validate() -> ValidationResult {
        var errorMessages: [String] = []
        
        if recipeImage == nil {
            errorMessages.append(AppStrings.Alerts.mainPhoto)
        }
        
        if recipeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessages.append(AppStrings.Alerts.mainTitle)
        }
        
        if recipeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessages.append(AppStrings.Alerts.mainDescription)
        }
        
        if categoriesDataSource.selectedCategories.isEmpty {
            errorMessages.append(AppStrings.Alerts.emptyCategory)
        }
        
        if ingredientsDataSource.ingredients.isEmpty {
            errorMessages.append(AppStrings.Alerts.emptyIngredient)
        }
        
        if instructionsDataSource.steps.isEmpty {
            errorMessages.append(AppStrings.Alerts.emptyStep)
        }
        
        return ValidationResult(
            isValid: errorMessages.isEmpty,
            errorMessages: errorMessages
        )
    }
}
