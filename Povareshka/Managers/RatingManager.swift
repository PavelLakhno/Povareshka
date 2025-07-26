//
//  RatingManager.swift
//  Povareshka
//
//  Created by user on 21.07.2025.
//

import UIKit
import Supabase

@MainActor
class RatingManager {
    static let shared = RatingManager()
    private init() {}
    
    func submitRating(recipeId: UUID, rating: Int, comment: String?) async throws {
        guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
            throw RatingError.userNotAuthenticated
        }
        
        let rating = Rating(
            id: UUID(),
            recipeId: recipeId,
            userId: userId,
            rating: rating,
            comment: comment,
            createdAt: Date()
        )
        
        // Используем upsert для обновления существующей оценки
        try await SupabaseManager.shared.client
            .from("ratings")
            .upsert(rating, onConflict: "recipe_id,user_id")
            .execute()
    }
    
    func getUserRating(for recipeId: UUID) async throws -> Rating? {
        guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
            throw RatingError.userNotAuthenticated
        }
        
        let ratings: [Rating] = try await SupabaseManager.shared.client
            .from("ratings")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return ratings.first
    }
    
    func getAverageRating(for recipeId: UUID) async throws -> Double {
        let response: [String: Double] = try await SupabaseManager.shared.client
            .rpc("get_average_rating", params: ["recipe_id": recipeId])
            .select()
            .single()
            .execute()
            .value
        
        return response["average"] ?? 0
    }
    
    func uploadPhotos(recipeId: UUID, photos: [UIImage]) async throws -> [String] {
        guard let userId = try await SupabaseManager.shared.getCurrentUserId() else {
            throw RatingError.userNotAuthenticated
        }
        
        var uploadedPaths: [String] = []
        
        for (index, photo) in photos.enumerated() {
            guard let imageData = photo.jpegData(compressionQuality: 0.8) else { continue }
            
            let fileName = "\(UUID().uuidString).jpg"
            let filePath = "reviews/\(recipeId)/\(fileName)"
            
            // Загружаем фото в Storage
            try await SupabaseManager.shared.client
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
            try await SupabaseManager.shared.client
                .from("review_photos")
                .insert([reviewPhotos])
                .execute()
        }
        
        return uploadedPaths
    }
    
    func loadReviewPhotos(recipeId: UUID, userId: UUID) async throws -> [UIImage] {
        // 1. Получаем метаданные фото из таблицы
        let photos: [ReviewPhoto] = try await SupabaseManager.shared.client
            .from("review_photos")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .order("order_index")
            .execute()
            .value
        
        // 2. Загружаем сами изображения из Storage
        var loadedImages: [UIImage] = []
        
        print("loading images")
        for photo in photos {
            do {
                let data = try await SupabaseManager.shared.client
                    .storage
                    .from("reviews") //"recipe_reviews"
                    .download(path: photo.photoPath)
                
                if let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
            } catch {
                print("Ошибка загрузки изображения \(photo.photoPath): \(error)")
                // Можно продолжить загрузку остальных фото
                continue
            }
        }
        
        return loadedImages
    }
    
    func getReviewPhotosInfo(recipeId: UUID, userId: UUID) async throws -> [ReviewPhoto] {
        return try await SupabaseManager.shared.client
            .from("review_photos")
            .select()
            .eq("recipe_id", value: recipeId)
            .eq("user_id", value: userId)
            .order("order_index")
            .execute()
            .value
    }
    

    func deletePhotos(paths: [String]) async throws {
        try await SupabaseManager.shared.client
            .storage
            .from("reviews")
            .remove(paths: paths)
        
        try await SupabaseManager.shared.client
            .from("review_photos")
            .delete()
            .in("photo_path", values: paths)
            .execute()
    }

    func getReviewPhotoURLs(recipeId: UUID) async throws -> [URL] {
        let photos: [ReviewPhoto] = try await SupabaseManager.shared.client
            .from("review_photos")
            .select()
            .eq("recipe_id", value: recipeId)
            .order("order_index")
            .execute()
            .value

        var urls: [URL] = []
        
        for photo in photos {
            do {
                let url = try SupabaseManager.shared.client
                    .storage
                    .from("reviews") //"recipe_reviews"
                    .getPublicURL(path: photo.photoPath)
                urls.append(url)
                print(urls)
            } catch {
                print("Ошибка получения URL для фото \(photo.photoPath): \(error)")
                // Продолжаем для остальных фото
                continue
            }
        }
        
        return urls
    }

}

enum RatingError: Error {
    case userNotAuthenticated
    case invalidRating
}
