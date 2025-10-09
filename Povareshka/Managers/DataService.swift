//
//  DataService.swift
//  Povareshka
//
//  Created by user on 31.07.2025.
//

import UIKit
import Storage

@MainActor 
final class DataService {
    static let shared = DataService()
    private let supabaseManager: SupabaseManager
    private let cache = NSCache<NSString, NSData>() // Для кэширования данных
    
    private init(supabaseManager: SupabaseManager = .shared) {
        self.supabaseManager = supabaseManager
    }
    
    // MARK: - Auth
    func getCurrentUserId() async throws -> UUID? {
        try await supabaseManager.getCurrentUserId()
    }
    
    func fetchUserProfile(userId: UUID) async throws -> UserProfile {
        return try await SupabaseManager.shared.client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }
    
    func fetchUserProfiles(userIds: [UUID]) async throws -> [UUID: UserProfileShort] {
        guard !userIds.isEmpty else { return [:] }
        
        let profiles: [UserProfileShort] = try await supabaseManager.client
            .from("profiles")
            .select()
            .in("id", values: userIds)
            .execute()
            .value
        
        var profilesDict: [UUID: UserProfileShort] = [:]
        profiles.forEach { profilesDict[$0.id] = $0 }
        return profilesDict
    }

    // MARK: - Save Recipe
    func saveRecipe(
        recipeId: UUID,
        title: String,
        description: String,
        image: UIImage?,
        servings: Int?,
        readyInMinutes: Int?,
        difficulty: Int?,
        ingredients: [Ingredient],
        steps: [Instruction],
        tags: [String],
        categories: [CategorySupabase]
    ) async throws {
        // 1. Загрузка изображения (если есть)
        let imagePath = try await uploadInstructionImage(image, for: recipeId)
        
        // 2. Сохранение метаданных рецепта
        try await saveRecipeMetadata(
            recipeId: recipeId,
            title: title,
            description: description,
            imagePath: imagePath,
            servings: servings,
            readyInMinutes: readyInMinutes,
            difficulty: difficulty
        )
        
        // 3. Сохранение связанных данных
        try await saveIngredients(ingredients, for: recipeId)
        try await saveInstructions(steps, for: recipeId)
        try await saveTags(tags, for: recipeId)
        try await saveCategories(categories, for: recipeId)
    }

    private func saveRecipeMetadata(
        recipeId: UUID,
        title: String,
        description: String,
        imagePath: String?,
        servings: Int?,
        readyInMinutes: Int?,
        difficulty: Int?
    ) async throws {
        let currentUser = try await supabaseManager.client.auth.session.user
        
        let recipe = RecipeSupabase(
            id: recipeId,
            userId: currentUser.id,
            title: title,
            description: description,
            imagePath: imagePath,
            readyInMinutes: readyInMinutes,
            servings: servings,
            difficulty: difficulty,
            isPublic: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await supabaseManager.client.from("recipes").insert(recipe).execute()
    }

    private func saveIngredients(_ ingredients: [Ingredient], for recipeId: UUID) async throws {
        for (index, ingredient) in ingredients.enumerated() {
            let ingredientSupabase = IngredientSupabase(
                id: UUID(),
                recipeId: recipeId,
                name: ingredient.name,
                amount: "\(ingredient.amount) \(ingredient.measure)",
                orderIndex: index
            )
            try await supabaseManager.client.from("ingredients").insert(ingredientSupabase).execute()
        }
    }
    
    private func saveInstructions(_ steps: [Instruction], for recipeId: UUID) async throws {
        for (index, step) in steps.enumerated() {
            var imagePath: String? = nil
            if let imageData = step.image, let image = UIImage(data: imageData) {
                imagePath = try await uploadInstructionImage(image, for: recipeId)
            }
            let instruction = InstructionSupabase(
                id: UUID(),
                recipeId: recipeId,
                stepNumber: index + 1,
                description: step.describe,
                imagePath: imagePath,
                orderIndex: index
            )
            try await supabaseManager.client.from("instructions").insert(instruction).execute()
        }
    }
    
    private func saveTags(_ tags: [String], for recipeId: UUID) async throws {
        for tag in tags {
            let recipeTag = RecipeTagSupabase(
                id: UUID(),
                recipeId: recipeId,
                tag: tag.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            )
            try await supabaseManager.client.from("recipe_tags").insert(recipeTag).execute()
        }
    }
    
    private func saveCategories(_ categories: [CategorySupabase], for recipeId: UUID) async throws {
        for category in categories {
            let recipeCategory = RecipeCategorySupabase(id: UUID(), recipeId: recipeId, categoryId: category.id)
            try await supabaseManager.client.from("recipe_categories").insert(recipeCategory).execute()
        }
    }
    
    // MARK: - Fetch Recipe Data
    func fetchRecipe(id: UUID) async throws -> RecipeSupabase {
        try await supabaseManager.client
            .from("recipes")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
    
    private func fetchIngredients(recipeId: UUID) async throws -> [IngredientSupabase] {
        try await supabaseManager.client
            .from("ingredients")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("order_index")
            .execute()
            .value
    }
    
    private func fetchInstructions(recipeId: UUID) async throws -> [InstructionSupabase] {
        try await supabaseManager.client
            .from("instructions")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("step_number")
            .execute()
            .value
    }
    
    private func fetchTags(recipeId: UUID) async throws -> [String] {
        let tags: [RecipeTagSupabase] = try await supabaseManager.client
            .from("recipe_tags")
            .select()
            .eq("recipe_id", value: recipeId)
            .execute()
            .value
        return tags.map { $0.tag }
    }
    
    private func fetchCategories(recipeId: UUID) async throws -> [CategorySupabase] {
        let recipeCategories: [RecipeCategorySupabase] = try await supabaseManager.client
            .from("recipe_categories")
            .select()
            .eq("recipe_id", value: recipeId)
            .execute()
            .value
        let categoryIds = recipeCategories.map { $0.categoryId }
        guard !categoryIds.isEmpty else { return [] }
        return try await supabaseManager.client
            .from("categories")
            .select()
            .in("id", values: categoryIds)
            .execute()
            .value
    }
    
    // MARK: - Favorites
    func isRecipeFavorite(recipeId: UUID) async throws -> Bool {
        guard let userId = try await supabaseManager.getCurrentUserId() else { return false }
        let favorites: [FavoriteRecipe] = try await supabaseManager.client
            .from("recipe_favorite")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
            .value
        return !favorites.isEmpty
    }
   
    func toggleFavorite(recipeId: UUID, isCurrentlyFavorite: Bool) async throws {
        if isCurrentlyFavorite {
            try await removeFromFavorites(recipeId: recipeId)
        } else {
            try await addToFavorites(recipeId: recipeId)
        }
    }
    
    private func addToFavorites(recipeId: UUID) async throws {
        guard let userId = try await supabaseManager.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        // Проверяем, не добавлен ли уже рецепт
        let isAlreadyFavorite = try await isRecipeFavorite(recipeId: recipeId)
        guard !isAlreadyFavorite else {
            throw RecipeError.alreadyInFavorites
        }
        
        let favorite = FavoriteRecipe(
            id: UUID(),
            recipeId: recipeId,
            userId: userId,
            createdAt: Date()
        )
        
        try await supabaseManager.client
            .from("recipe_favorite")
            .insert(favorite)
            .execute()
    }

    private func removeFromFavorites(recipeId: UUID) async throws {
        guard let userId = try await supabaseManager.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        try await supabaseManager.client
            .from("recipe_favorite")
            .delete()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
    }

    // MARK: - Review Photos
    func uploadReviewPhotos(recipeId: UUID, photos: [UIImage]) async throws -> [String] {
        guard let userId = try await supabaseManager.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        var uploadedPaths: [String] = []
        
        for (index, photo) in photos.enumerated() {
            guard let imageData = photo.jpegData(compressionQuality: 0.8) else { continue }
            
            let fileName = "\(UUID().uuidString).jpg"
            let filePath = "reviews/\(recipeId)/\(fileName)"
            
            // Загружаем фото в Storage
            try await supabaseManager.client
                .storage
                .from("reviews") // Название bucket'а в Supabase Storage
                .upload(
                    filePath,
                    data: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            uploadedPaths.append(filePath)
            
            // Сохраняем метаданные в таблицу photos
            let reviewPhotos = ReviewPhoto(
                id: UUID(),
                recipeId: recipeId,
                userId: userId,
                photoPath: filePath,
                orderIndex: index
            )
            try await supabaseManager.client
                .from("review_photos")
                .insert([reviewPhotos])
                .execute()
        }
        
        return uploadedPaths
    }
    
    func fetchUserReviewPhotos(recipeId: UUID, userId: UUID) async throws -> [ReviewPhoto] {
        return try await supabaseManager.client
            .from("review_photos")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .order("order_index")
            .execute()
            .value
    }
    
    func fetchAllReviewPhotos(recipeId: UUID) async throws -> [ReviewPhoto] {
        return try await supabaseManager.client
            .from("review_photos")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("order_index")
            .execute()
            .value
    }
    
    func loadReviewImages(recipeId: UUID, userId: UUID) async throws -> [UIImage] {
        let photos = try await fetchUserReviewPhotos(recipeId: recipeId, userId: userId)
        var loadedImages: [UIImage] = []
        
        for photo in photos {
            let data = try await supabaseManager.client
                .storage
                .from("reviews")
                .download(path: photo.photoPath)
            
            guard let image = UIImage(data: data) else {
                throw ImageError.invalidImageData
            }
            
            loadedImages.append(image)
        }
        
        return loadedImages
    }
    
    func removeReviewPhotos(paths: [String]) async throws {
        try await supabaseManager.client
            .storage
            .from("reviews")
            .remove(paths: paths)
        
        try await supabaseManager.client
            .from("review_photos")
            .delete()
            .in("photo_path", values: paths)
            .execute()
    }

    
    
    
    
    
    
    
    
    

    

    
    func fetchRecipesShortInfo() async throws -> [RecipeShortInfo] {
        try await supabaseManager.client
            .from("recipes")
            .select("""
                    id,
                    title,
                    image_path,
                    user_id,
                    profiles!recipes_user_id_fkey(username, avatar_url)
                """)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    

    
    // MARK: - Ratings
    func fetchUserRating(recipeId: UUID) async throws -> Rating? {
        guard let userId = try await supabaseManager.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        let ratings: [Rating] = try await supabaseManager.client
            .from("ratings")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
            .value
        return ratings.first
    }
    
    func submitRating(recipeId: UUID, rating: Int, comment: String?) async throws {
        guard let userId = try await supabaseManager.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        let rating = Rating(
            id: UUID(),
            recipeId: recipeId,
            userId: userId,
            rating: rating,
            comment: comment,
            createdAt: Date()
        )
        try await supabaseManager.client
            .from("ratings")
            .upsert(rating, onConflict: "recipe_id,user_id")
            .execute()
    }
    
    func fetchAverageRating(recipeId: UUID) async throws -> Double {
        let response: [String: Double] = try await supabaseManager.client
            .rpc("get_average_rating", params: ["recipe_id": recipeId])
            .select()
            .single()
            .execute()
            .value
        return response["average"] ?? 0
    }
    
    func fetchRatings(recipeId: UUID) async throws -> [Rating] {
        return try await supabaseManager.client
            .from("ratings")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    

    

    
    func loadImage(from path: String, bucket: String) async throws -> UIImage {
        if let cachedImage = ImageCache.shared.image(for: path) {
            return cachedImage
        }

        let data = try await supabaseManager.client
            .storage
            .from(bucket)
            .download(path: path)
        
        guard !Task.isCancelled else {
            throw ImageError.operationCancelled
        }
        
        guard let image = UIImage(data: data) else {
            throw ImageError.invalidImageData
        }

        ImageCache.shared.setImage(image, for: path)
        return image
    }
    
    // MARK: - Private Helpers
    private func uploadInstructionImage(_ image: UIImage?, for recipeId: UUID) async throws -> String? {
        guard let image = image, image != AppImages.Icons.cameraMain else { return nil }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        let currentUser = try await supabaseManager.client.auth.session.user
        let userId = currentUser.id.uuidString.lowercased()
        let fileName = "main_\(UUID().uuidString).jpeg"
        let fullPath = "\(userId)/\(recipeId)/\(fileName)"
        try await supabaseManager.client.storage
            .from("recipes")
            .upload(fullPath, data: imageData, options: FileOptions(contentType: "image/jpeg"))
        return fullPath
    }

    
    func fetchRecipeDetails(recipeId: UUID) async throws -> RecipeDetailsResponse {
        
        async let recipeTask = fetchRecipe(id: recipeId)
        async let ingredientsTask = fetchIngredients(recipeId: recipeId)
        async let instructionsTask = fetchInstructions(recipeId: recipeId)
        async let tagsTask = fetchTags(recipeId: recipeId)
        async let categoriesTask = fetchCategories(recipeId: recipeId)
        async let averageRatingTask = fetchAverageRating(recipeId: recipeId)
        async let userRatingTask = fetchUserRating(recipeId: recipeId)
        
        do {
            let (recipe, ingredients, instructions, tags, categories, averageRating, userRating) = await (
                try recipeTask,
                try ingredientsTask,
                try instructionsTask,
                try tagsTask,
                try categoriesTask,
                try averageRatingTask,
                try userRatingTask
            )
            
            return RecipeDetailsResponse(
                recipe: recipe,
                ingredients: ingredients,
                instructions: instructions,
                tags: tags,
                categories: categories,
                averageRating: averageRating,
                userRating: userRating
            )
        } catch {
            // Можно добавить более детальную обработку ошибок
            print("Error fetching recipe details: \(error)")
            throw error
        }
    }
}



