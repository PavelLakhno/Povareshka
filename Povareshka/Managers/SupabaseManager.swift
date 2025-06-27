//
//  SapobaseManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 17.04.2025.
//

import Foundation
import Supabase


final class SupabaseManager: Sendable {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Resources.Auth.supabaseUrl)!,
            supabaseKey: Resources.Auth.supabaseKey,
        )
    }
    
    func getCurrentUserId() async throws -> UUID? {
        // Получаем текущую сессию
        let session = try await client.auth.session
        
        // Возвращаем ID пользователя, если он есть
        return UUID(uuidString: session.user.id.uuidString.lowercased())
    }
    
}

extension SupabaseManager {
    // MARK: - Ratings
    func fetchUserRating(recipeId: UUID, userId: UUID) async throws -> Rating? {
        let ratings: [Rating] = try await client
            .from("ratings")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return ratings.first
    }
    
//    func saveRating(recipeId: UUID, userId: UUID, rating: Int, comment: String?) async throws {
//        let ratingData: [String: Any] = [
//            "recipe_id": recipeId,
//            "user_id": userId,
//            "rating": rating,
//            "comment": comment as Any
//        ]
//        
//        try await client
//            .from("ratings")
//            .upsert(ratingData)
//            .execute()
//    }
//    
//    func fetchAverageRating(recipeId: UUID) async throws -> Double {
//        let result: Void = try await client
//            .rpc("get_average_rating", params: ["recipe_id": recipeId])
//            .execute()
//            .value
//        
//        return result.first?["average_rating"] as? Double
//    }
    
    // MARK: - Favorites
    
    func checkIfFavorite(recipeId: UUID, userId: UUID) async throws -> Bool {
        let favorites: [FavoriteRecipe] = try await client
            .from("favorites")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return !favorites.isEmpty
    }
    
    func toggleFavorite(recipeId: UUID, userId: UUID, isFavorite: Bool) async throws {
        if isFavorite {
            try await client
                .from("favorites")
                .insert(["recipe_id": recipeId, "user_id": userId])
                .execute()
        } else {
            try await client
                .from("favorites")
                .delete()
                .eq("recipe_id", value: recipeId)
                .eq("user_id", value: userId)
                .execute()
        }
    }
}
    

