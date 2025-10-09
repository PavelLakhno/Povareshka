//
//  RecipeDataService.swift
//  Povareshka
//
//  Created by user on 23.09.2025.
//

import UIKit

@MainActor
final class RecipeWatchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var recipeDetails: RecipeDetailsResponse?
    @Published var isLoading = false
    @Published var error: AppError?
    
    // MARK: - Private Properties
    private let dataService: DataService
    
    // MARK: - Computed Properties (для удобства)
    var recipe: RecipeSupabase? { recipeDetails?.recipe }
    var ingredients: [IngredientSupabase] { recipeDetails?.ingredients ?? [] }
    var instructions: [InstructionSupabase] { recipeDetails?.instructions ?? [] }
    var tags: [String] { recipeDetails?.tags ?? [] }
    var categories: [CategorySupabase] { recipeDetails?.categories ?? [] }
    var averageRating: Double { recipeDetails?.averageRating ?? 0 }
    var userRating: Rating? { recipeDetails?.userRating }
    
    // MARK: - Init
    init(dataService: DataService = .shared) {
        self.dataService = dataService
    }
    
    // MARK: - Public Methods
    func loadRecipe(recipeId: UUID) async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            let results = try await dataService.fetchRecipeDetails(recipeId: recipeId)
            self.recipeDetails = results
        } catch let appError as AppError {
            self.error = appError
        } catch {
            self.error = DataError.operationFailed(description: error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    func loadRecipeImage(for recipe: RecipeSupabase) async -> UIImage? {
        guard let imagePath = recipe.imagePath else { return nil }
        
        do {
            return try await dataService.loadImage(from: imagePath, bucket: Bucket.recipes)
        } catch {
            print("Ошибка загрузки изображения: \(error)")
            return nil
        }
    }
    
    func checkIfCurrentUserIsCreator(recipe: RecipeSupabase) async -> Bool {
        do {
            guard let currentUserId = try await dataService.getCurrentUserId(),
                  let creatorId = UUID(uuidString: recipe.userId.uuidString.lowercased()) else {
                return false
            }
            return currentUserId == creatorId
        } catch {
            print("Ошибка получения текущего пользователя: \(error)")
            return false
        }
    }
    
    func checkIfRecipeIsFavorite(recipeId: UUID) async throws -> Bool {
        return try await dataService.isRecipeFavorite(recipeId: recipeId)
    }
    
    // MARK: - UI Helper Properties
    var hasDescription: Bool {
        recipe?.description?.isEmpty == false
    }
    
    var hasCategories: Bool {
        !categories.isEmpty
    }
    
    var hasTags: Bool {
        !tags.isEmpty
    }
    
    var rateButtonTitle: String {
        userRating != nil ? "Изменить оценку" : "Оценить рецепт"
    }
    
    var categoriesSectionHeight: CGFloat {
        let rows = ceil(Double(categories.count) / 3.0)
        return rows * 100 + (rows - 1) * 8
    }
}
