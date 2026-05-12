//
//  DataService.swift
//  Povareshka
//
//  Created by user on 31.07.2025.
//

import UIKit
import Storage
import Kingfisher

@MainActor
final class DataService {
    static let shared = DataService()
    private let supabaseManager: SupabaseManager

    // Cached categories — initialised with hardcoded fallback, refreshed from server by loadCategories()
    private(set) var categories: [CategorySupabase] = CategorySupabase.allCategories()
    private var categoriesLoaded = false

    private init(supabaseManager: SupabaseManager = .shared) {
        self.supabaseManager = supabaseManager
    }

    // MARK: - Categories

    func loadCategories() async {
        guard !categoriesLoaded else { return }
        do {
            let fetched: [CategorySupabase] = try await supabaseManager.client
                .from("categories")
                .select()
                .order("id")
                .execute()
                .value
            if !fetched.isEmpty {
                categories = fetched
                categoriesLoaded = true
            }
        } catch {
            // Keep hardcoded fallback on error
        }
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
        let imagePath = try await uploadRecipeImage(image, for: recipeId)
        
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
    
    private func saveIngredients(_ ingredients: [Ingredient], for recipeId: UUID) async throws { //Ingredient
        for (index, ingredient) in ingredients.enumerated() {
            let ingredientSupabase = IngredientSupabase(
                id: UUID(),
                recipeId: recipeId,
                name: ingredient.name,
                amount: "\(ingredient.amount) \(ingredient.measure)",
                measure: ingredient.measure,
                orderIndex: index
            )
            try await supabaseManager.client.from("ingredients").insert(ingredientSupabase).execute()
        }
    }
    
    private func saveInstructions(_ steps: [Instruction], for recipeId: UUID) async throws {
        for (index, step) in steps.enumerated() {
            var imagePath: String? = nil
            if let imageData = step.image, let image = UIImage(data: imageData) {
                imagePath = try await uploadInstructionImage(image, forStep: index+1, currentRecipeID: recipeId)
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
    
    private func fetchTags(recipeId: UUID) async throws -> [RecipeTagSupabase] { //[String]
        let tags: [RecipeTagSupabase] = try await supabaseManager.client
            .from("recipe_tags")
            .select()
            .eq("recipe_id", value: recipeId)
            .execute()
            .value
//        return tags.map { $0.tag }
        return tags
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
    
    func getFavoritesCount(recipeId: UUID) async throws -> Int {
        let favorites: [FavoriteRecipe] = try await supabaseManager.client
            .from("recipe_favorite")
            .select()
            .eq("recipe_id", value: recipeId)
            .execute()
            .value
        
        return favorites.count
    }
    
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
   
    func toggleFavorite(recipeId: UUID, isCurrentlyFavorite: Bool) async throws -> Bool {
        if isCurrentlyFavorite {
            try await removeFromFavorites(recipeId: recipeId)
            return false
        } else {
            try await addToFavorites(recipeId: recipeId)
            return true
        }
    }
    
    private func addToFavorites(recipeId: UUID) async throws {
        guard let userId = try await supabaseManager.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        // Проверяем, не добавлен ли уже рецепт
        let isAlreadyFavorite = try await isRecipeFavorite(recipeId: recipeId)
        guard !isAlreadyFavorite else {
            // Если уже в избранном, просто возвращаемся
            return
        }
        
        let favorite = FavoriteRecipe(
            id: UUID(),
            recipeId: recipeId,
            userId: userId,
            createdAt: Date()
        )
        
        do {
            try await supabaseManager.client
                .from("recipe_favorite")
                .insert(favorite)
                .execute()
        } catch {
            // Игнорируем ошибку дубликата, так как рецепт уже в избранном
            if !error.localizedDescription.contains("duplicate key") {
                throw error
            }
        }
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
//MARK: fetchRecipesShortInfo
    func fetchRecipesShortInfo() async throws -> [RecipeShortInfo] {
        try await supabaseManager.client
            .from("recipes")
            .select("""
                    id,
                    title,
                    image_path,
                    user_id,
                    ready_in_minutes,
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
    
    // MARK: - Private Helpers
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
            throw error
        }
    }
}

// MARK: - Image Loading with Kingfisher
extension DataService {

    func getImageURL(for path: String, bucket: String) async throws -> URL {
        return try await supabaseManager.getDownloadURL(bucket: bucket, path: path)
    }
    
    func loadReviewImages(recipeId: UUID, userId: UUID) async throws -> [UIImage] {
        let photos = try await fetchUserReviewPhotos(recipeId: recipeId, userId: userId)
        var loadedImages: [UIImage] = []
        
        for photo in photos {
            do {
                let url = try await getImageURL(for: photo.photoPath, bucket: Bucket.reviews)
                if let image = await loadImageWithKingfisher(url: url) {
                    loadedImages.append(image)
                }
            } catch {
                continue
            }
        }
        
        return loadedImages
    }
    
    func loadImageWithKingfisher(url: URL) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}

// MARK: upload images with max size 100kb
extension DataService {
    private func uploadRecipeImage(_ image: UIImage?, for recipeId: UUID) async throws -> String? {
        guard let image = image, image != AppImages.Icons.cameraMain else { return nil }
        
        // Максимальный размер в байтах
        let maxSizeInBytes = 100 * 1024 // 100 КБ
        
        guard let imageData = compressImage(image, toMaxSize: maxSizeInBytes) else { return nil }
        
        let currentUser = try await supabaseManager.client.auth.session.user
        let userId = currentUser.id.uuidString.lowercased()
        let fileName = "main_\(UUID().uuidString).jpeg"
        let fullPath = "\(userId)/\(recipeId)/\(fileName)"
        
        try await supabaseManager.client.storage
            .from("recipes")
            .upload(fullPath, data: imageData, options: FileOptions(contentType: "image/jpeg"))
        return fullPath
    }
    
    private func uploadInstructionImage(_ image: UIImage, forStep stepNumber: Int, currentRecipeID: UUID) async throws -> String? {
        
        // Максимальный размер в байтах
        let maxSizeInBytes = 100 * 1024 // 100 КБ
        
        guard let imageData = compressImage(image, toMaxSize: maxSizeInBytes) else { return nil }
        
        let currentUser = try await SupabaseManager.shared.client.auth.session.user
        let userId = currentUser.id.uuidString.lowercased()
        let recipeId = currentRecipeID
        let fileName = "step_\(stepNumber)_\(UUID().uuidString).jpeg"
        let fullPath = "\(userId)/\(recipeId)/\(fileName)"
        
        try await SupabaseManager.shared.client.storage
            .from("recipes")
            .upload(
                fullPath,
                data: imageData,
                options: FileOptions(
                    contentType: "image/jpeg",
                )
            )
        return fullPath
    }
    
    private func compressImage(_ image: UIImage, toMaxSize maxSize: Int) -> Data? {
        let minQuality: CGFloat = 0.1
        let maxSizeInBytes = maxSize
        
        // Попытка сжатия через качество
        var compressionQuality: CGFloat = 0.8
        var imageData = image.jpegData(compressionQuality: compressionQuality)
        
        while imageData?.count ?? 0 > maxSizeInBytes && compressionQuality > minQuality {
            compressionQuality -= 0.1
            imageData = image.jpegData(compressionQuality: compressionQuality)
        }
        
        // Если сжатия качеством недостаточно - уменьшаем размер
        if imageData?.count ?? 0 > maxSizeInBytes {
            return compressImageByScaling(image, toMaxSize: maxSizeInBytes)
        }
        
        return imageData
    }
    
    private func compressImageByScaling(_ image: UIImage, toMaxSize maxSize: Int) -> Data? {
        let minQuality: CGFloat = 0.1
        var currentImage = image
        var scaleFactor: CGFloat = 0.9
        
        while let imageData = currentImage.jpegData(compressionQuality: minQuality),
              imageData.count > maxSize && scaleFactor > 0.1 {
            
            let newSize = CGSize(
                width: currentImage.size.width * scaleFactor,
                height: currentImage.size.height * scaleFactor
            )
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            currentImage.draw(in: CGRect(origin: .zero, size: newSize))
            currentImage = UIGraphicsGetImageFromCurrentImageContext() ?? currentImage
            UIGraphicsEndImageContext()
            
            scaleFactor -= 0.1
        }
        
        return currentImage.jpegData(compressionQuality: minQuality)
    }
}

// Search Recipes
extension DataService {
    func searchRecipes(
            query: String? = nil,
            categoryTitles: [String] = [],
            maxCookingTime: Int? = nil
        ) async throws -> [RecipeShortInfo] {
            
            // Если запрос пустой - используем обычный поиск
            guard let query = query, !query.isEmpty else {
                return try await searchRecipesWithoutQuery(
                    categoryTitles: categoryTitles,
                    maxCookingTime: maxCookingTime
                )
            }
            
            // Ищем рецепты по названию
            let titleRecipes = try await searchRecipesByTitle(
                query: query,
                categoryTitles: categoryTitles,
                maxCookingTime: maxCookingTime
            )
            
            // Ищем рецепты по тегам
            let tagRecipes = try await searchRecipesByTags(
                query: query,
                categoryTitles: categoryTitles,
                maxCookingTime: maxCookingTime
            )
            
            // Объединяем результаты, убирая дубликаты
            let allRecipes = (titleRecipes + tagRecipes).reduce(into: [RecipeShortInfo]()) { result, recipe in
                if !result.contains(where: { $0.id == recipe.id }) {
                    result.append(recipe)
                }
            }
            
            return allRecipes
        }
        
        // Вспомогательный метод для поиска по названию
        private func searchRecipesByTitle(
            query: String,
            categoryTitles: [String] = [],
            maxCookingTime: Int? = nil
        ) async throws -> [RecipeShortInfo] {
            
            var request = supabaseManager.client
                .from("recipes")
                .select("""
                    id,
                    title,
                    image_path,
                    user_id,
                    ready_in_minutes,
                    profiles!recipes_user_id_fkey(username, avatar_url)
                """)
                .eq("is_public", value: true)
                .ilike("title", pattern: "%\(query)%")
            
            if let maxCookingTime = maxCookingTime, maxCookingTime > 0 {
                request = request.lte("ready_in_minutes", value: maxCookingTime)
            }
            
            let recipes: [RecipeShortInfo] = try await request
                .order("created_at", ascending: false)
                .execute()
                .value
            
            // Фильтрация по категориям
            if !categoryTitles.isEmpty {
                return try await filterRecipesByCategories(recipes, categoryTitles: categoryTitles)
            }
            
            return recipes
        }
        
        // Новый метод для поиска по тегам
    private func searchRecipesByTags(
        query: String,
        categoryTitles: [String] = [],
        maxCookingTime: Int? = nil
    ) async throws -> [RecipeShortInfo] {
        
        let matchingTags: [RecipeTagSupabase] = try await supabaseManager.client
            .from("recipe_tags")
            .select()
            .ilike("tag", pattern: "%\(query)%")
            .execute()
            .value

        let recipeIds = matchingTags.map { $0.recipeId }
        guard !recipeIds.isEmpty else { return [] }
        
        // Затем получаем рецепты по найденным ID
        var request = supabaseManager.client
            .from("recipes")
            .select("""
                id,
                title,
                image_path,
                user_id,
                ready_in_minutes,
                profiles!recipes_user_id_fkey(username, avatar_url)
            """)
            .eq("is_public", value: true)
            .in("id", values: recipeIds) //
        
        if let maxCookingTime = maxCookingTime, maxCookingTime > 0 {
            request = request.lte("ready_in_minutes", value: maxCookingTime)
        }
        
        let recipes: [RecipeShortInfo] = try await request
            .order("created_at", ascending: false)
            .execute()
            .value
        
        if !categoryTitles.isEmpty {
            return try await filterRecipesByCategories(recipes, categoryTitles: categoryTitles)
        }

        return recipes
    }
        
        // Метод для поиска без текстового запроса (только фильтры)
        private func searchRecipesWithoutQuery(
            categoryTitles: [String] = [],
            maxCookingTime: Int? = nil
        ) async throws -> [RecipeShortInfo] {
            
            var request = supabaseManager.client
                .from("recipes")
                .select("""
                    id,
                    title,
                    image_path,
                    user_id,
                    ready_in_minutes,
                    profiles!recipes_user_id_fkey(username, avatar_url)
                """)
                .eq("is_public", value: true)
            
            if let maxCookingTime = maxCookingTime, maxCookingTime > 0 {
                request = request.lte("ready_in_minutes", value: maxCookingTime)
            }
            
            let recipes: [RecipeShortInfo] = try await request
                .order("created_at", ascending: false)
                .execute()
                .value
            
            // Фильтрация по категориям
            if !categoryTitles.isEmpty {
                return try await filterRecipesByCategories(recipes, categoryTitles: categoryTitles)
            }
            
            return recipes
        }
    
    private func filterRecipesByCategories(_ recipes: [RecipeShortInfo], categoryTitles: [String]) async throws -> [RecipeShortInfo] {
        guard !recipes.isEmpty else { return [] }

        let recipeIds = recipes.map { $0.id }

        let allLinks: [RecipeCategorySupabase] = try await supabaseManager.client
            .from("recipe_categories")
            .select()
            .in("recipe_id", values: recipeIds)
            .execute()
            .value

        let targetIds = Set(
            categories.filter { categoryTitles.contains($0.title) }.map { $0.id }
        )

        let linksByRecipe = Dictionary(grouping: allLinks, by: { $0.recipeId })

        return recipes.filter { recipe in
            let recipeCategoryIds = Set((linksByRecipe[recipe.id] ?? []).map { $0.categoryId })
            return targetIds.isSubset(of: recipeCategoryIds)
        }
    }
}
