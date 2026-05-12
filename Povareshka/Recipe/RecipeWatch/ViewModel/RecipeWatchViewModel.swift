//
//  RecipeDataService.swift
//  Povareshka
//
//  Created by user on 23.09.2025.
//

import UIKit

// MARK: - Universal ViewModel
@MainActor
final class RecipeWatchViewModel: ObservableObject {
    
    // MARK: - Properties
    private let dataService = DataService.shared
    
    // Online данные
    private var onlineRecipeDetails: RecipeDetailsResponse?
    
    // Offline данные
    private var offlineRecipe: RecipeModel?
    
    // Unified interface
    var isOnline: Bool { onlineRecipeDetails != nil }
    var hasData: Bool { onlineRecipeDetails != nil || offlineRecipe != nil }
    
    // Computed properties для универсального доступа
    var title: String {
        if let online = onlineRecipeDetails?.recipe {
            return online.title
        } else if let offline = offlineRecipe {
            return offline.title
        }
        return ""
    }
    
    var description: String? {
        if let online = onlineRecipeDetails?.recipe.description {
            return online
        } else if let offline = offlineRecipe?.recipeDescription {
            return offline
        }
        return nil
    }
    
    var ingredients: [IngredientSupabase] {
        if let online = onlineRecipeDetails?.ingredients {
            return online
        } else if let offline = offlineRecipe {
            return offline.ingredients.map { ingredient in
                IngredientSupabase(
                    id: ingredient.id,
                    recipeId: offline.id,
                    name: ingredient.name,
                    amount: ingredient.amount,
                    measure: ingredient.measure,
                    orderIndex: ingredient.orderIndex
                )
            }
        }
        return []
    }
    
    var instructions: [UniversalInstruction] {
        if let online = onlineRecipeDetails?.instructions {
            return online.map { UniversalInstruction(from: $0) }
        } else if let offline = offlineRecipe {
            return offline.instructions.map { UniversalInstruction(from: $0) }
        }
        return []
    }
    
    var tags: [RecipeTagSupabase] {
        if let online = onlineRecipeDetails?.tags {
            return online
        } else if let offline = offlineRecipe {
            return offline.tags.map { tag in
                RecipeTagSupabase(
                    id: tag.id,
                    recipeId: tag.recipeId,
                    tag: tag.name
                )
            }
        }
        return []
    }
    
    var categories: [CategorySupabase] {
        if let online = onlineRecipeDetails?.categories {
            return online
        } else if let offline = offlineRecipe {
            return offline.categories.map { category in
                CategorySupabase(
                    id: category.id,
                    title: category.title,
                    iconName: category.iconName
                )
            }
        }
        return []
    }
    
    var averageRating: Double {
        onlineRecipeDetails?.averageRating ?? 0
    }
    
    var userRating: Rating? {
        onlineRecipeDetails?.userRating
    }
    
    var recipeId: UUID? {
        onlineRecipeDetails?.recipe.id ?? offlineRecipe?.id
    }
    
    var metaData: RecipeMetaData {
        if let online = onlineRecipeDetails?.recipe {
            return RecipeMetaData(
                readyInMinutes: online.readyInMinutes,
                servings: online.servings,
                difficulty: online.difficulty
            )
        } else if let offline = offlineRecipe {
            return RecipeMetaData(
                readyInMinutes: offline.readyInMinutes,
                servings: offline.servings,
                difficulty: offline.difficulty
            )
        }
        return RecipeMetaData()
    }
    
    var recipeDetails: RecipeDetailsResponse? { onlineRecipeDetails }
    var imageData: Data?
    var instructionImagesData: [UUID: Data] = [:]
    
    // UI Helpers
    var hasDescription: Bool { description?.isEmpty == false }
    var hasCategories: Bool { !categories.isEmpty }
    var hasTags: Bool { !tags.isEmpty }
    var rateButtonTitle: String { userRating != nil ? "Изменить оценку" : "Оценить рецепт" }
    
    // MARK: - Public Methods
    func loadOnlineRecipe(recipeId: UUID) async {
        do {
            let results = try await dataService.fetchRecipeDetails(recipeId: recipeId)
            self.onlineRecipeDetails = results
        } catch {
        }
    }
    
    func loadOfflineRecipe(recipeModel: RecipeModel) async {
        self.offlineRecipe = recipeModel
        self.imageData = recipeModel.imageData
        
        // Загружаем изображения инструкций для оффлайн рецепта
        for instruction in recipeModel.instructions {
            if let imageData = instruction.imageData {
                self.instructionImagesData[instruction.id] = imageData
            }
        }
    }
    
    func loadRecipeImage() async -> UIImage? {
        if let onlineRecipe = onlineRecipeDetails?.recipe {
            return await loadOnlineRecipeImage(for: onlineRecipe)
        } else if let offlineRecipe = offlineRecipe, let imageData = offlineRecipe.imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func loadInstructionImages() async {
        guard let instructions = onlineRecipeDetails?.instructions else { return }
        
        await withTaskGroup(of: (UUID, Data?).self) { group in
            for instruction in instructions {
                guard let imagePath = instruction.imagePath else { continue }
                
                group.addTask {
                    do {
                        let url = try await self.dataService.getImageURL(for: imagePath, bucket: Bucket.recipes)
                        if let image = await self.dataService.loadImageWithKingfisher(url: url),
                           let imageData = image.jpegData(compressionQuality: 0.7) {
                            return (instruction.id, imageData)
                        }
                    } catch {}
                    return (instruction.id, nil)
                }
            }
            
            for await (instructionId, imageData) in group {
                if let imageData = imageData {
                    self.instructionImagesData[instructionId] = imageData
                }
            }
        }
    }
    
    func checkIfCurrentUserIsCreator() async -> Bool {
        guard let onlineRecipe = onlineRecipeDetails?.recipe else { return false }
        
        do {
            guard let currentUserId = try await dataService.getCurrentUserId(),
                  let creatorId = UUID(uuidString: onlineRecipe.userId.uuidString.lowercased()) else {
                return false
            }
            return currentUserId == creatorId
        } catch {
            return false
        }
    }
    
    func checkIfRecipeIsFavorite() async -> Bool {
        guard let recipeId = recipeId else { return false }
        
        do {
            return try await dataService.isRecipeFavorite(recipeId: recipeId)
        } catch {
            return false
        }
    }
    
    // MARK: - Private Methods
    private func loadOnlineRecipeImage(for recipe: RecipeSupabase) async -> UIImage? {
        guard let imagePath = recipe.imagePath else { return nil }
        
        do {
            let url = try await dataService.getImageURL(for: imagePath, bucket: Bucket.recipes)
            let image = await dataService.loadImageWithKingfisher(url: url)
            self.imageData = image?.jpegData(compressionQuality: 0.8)
            return image
        } catch {
            return nil
        }
    }
}
