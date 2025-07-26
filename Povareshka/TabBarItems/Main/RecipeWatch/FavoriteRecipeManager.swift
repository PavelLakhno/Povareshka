//
//  FavoriteRecipeManager.swift
//  Povareshka
//
//  Created by user on 22.07.2025.
//

import UIKit

@MainActor
class FavoriteRecipeManager {
    static let shared = FavoriteRecipeManager()
    private init() {}
    
    // Проверяем, находится ли рецепт в избранном
    func isRecipeFavorite(recipeId: UUID) async throws -> Bool {
        guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
            return false
        }
        
        let favorites: [FavoriteRecipe] = try await SupabaseManager.shared.client
            .from("recipe_favorite")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return !favorites.isEmpty
    }
    
    // Добавляем рецепт в избранное
    func addToFavorites(recipeId: UUID) async throws {
        guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let favorite = FavoriteRecipe(
            id: UUID(),
            recipeId: recipeId,
            userId: userId,
            createdAt: Date()
        )
        
        try await SupabaseManager.shared.client
            .from("recipe_favorite")
            .insert(favorite)
            .execute()
    }
    
    // Удаляем рецепт из избранного
    func removeFromFavorites(recipeId: UUID) async throws {
        guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        try await SupabaseManager.shared.client
            .from("recipe_favorite")
            .delete()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
    }
    
    // Получаем все избранные рецепты пользователя
    func getFavoriteRecipes() async throws -> [FavoriteRecipe] {
        guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        return try await SupabaseManager.shared.client
            .from("recipe_favorite")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
