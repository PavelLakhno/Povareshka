//
//  Recipes.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.11.2024.
//

import Foundation

// Структура для ответа RPC
struct RecipeDetailsResponse: Codable {
    let recipe: RecipeSupabase
    let ingredients: [IngredientSupabase]
    let instructions: [InstructionSupabase]
    let tags: [RecipeTagSupabase]
    let categories: [CategorySupabase]
    let averageRating: Double
    let userRating: Rating?
    
    enum CodingKeys: String, CodingKey {
        case recipe, ingredients, instructions, tags, categories
        case averageRating = "average_rating"
        case userRating = "user_rating"
    }
}

// Структура для ответа поиска
struct RecipeSearchResponse: Decodable {
    let id: UUID
    let userId: UUID
    let title: String
    let imagePath: String?
    let readyInMinutes: Int?
    let recipeCategories: [RecipeCategoryResponse]?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case userId = "user_id"
        case imagePath = "image_path"
        case readyInMinutes = "ready_in_minutes"
        case recipeCategories = "recipe_categories"
    }
}

struct RecipeSupabase: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String?
    let imagePath: String?
    let readyInMinutes: Int?
    let servings: Int?
    let difficulty: Int?
    let isPublic: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case imagePath = "image_path"
        case readyInMinutes = "ready_in_minutes"
        case servings
        case difficulty
        case isPublic = "is_public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct IngredientSupabase: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let name: String
    let amount: String
    let measure: String
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case amount
        case measure
        case orderIndex = "order_index"
    }
}


struct InstructionSupabase: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let stepNumber: Int
    let description: String?
    let imagePath: String?
    let orderIndex: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case stepNumber = "step_number"
        case description
        case imagePath = "image_path"
        case orderIndex = "order_index"
    }
}

// MARK: - RecipeTagSupabase
struct RecipeTagSupabase: Codable {
    let id: UUID
    let recipeId: UUID
    let tag: String
    
    enum CodingKeys: String, CodingKey {
        case id, tag
        case recipeId = "recipe_id"
    }
}

struct RecipeCategorySupabase: Codable {
    let id: UUID
    let recipeId: UUID
    let categoryId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case categoryId = "category_id"
    }
}

struct CategorySupabase: Codable, Identifiable, Hashable  {
    let id: UUID
    let title: String
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case iconName = "icon_name"
    }
    
    static func from(title: String) -> CategorySupabase? {
        return allCategories().first { $0.title == title }
    }
    
    static func from(titles: [String]) -> [CategorySupabase] {
        return titles.compactMap { from(title: $0) }
    }
    
    static func allCategories() -> [CategorySupabase] {
        let data: [(String, String, String)] = [
            ("00000000-0000-0000-0000-000000000001", "Завтраки", "breakfast"),
            ("00000000-0000-0000-0000-000000000002", "Основные блюда", "mainCourses"),
            ("00000000-0000-0000-0000-000000000003", "Супы", "soups"),
            ("00000000-0000-0000-0000-000000000004", "Салаты", "salads"),
            ("00000000-0000-0000-0000-000000000005", "Закуски", "appetizers"),
            ("00000000-0000-0000-0000-000000000006", "Десерты", "desserts"),
            ("00000000-0000-0000-0000-000000000007", "Выпечка", "pastries"),
            ("00000000-0000-0000-0000-000000000008", "Напитки", "drinks"),
            ("00000000-0000-0000-0000-000000000009", "Соусы и маринады", "saucesAndMarinades"),
            ("00000000-0000-0000-0000-000000000010", "Паста и пицца", "pastaAndPizza"),
            ("00000000-0000-0000-0000-000000000011", "Мясные блюда", "meatDishes"),
            ("00000000-0000-0000-0000-000000000012", "Рыба и морепродукты", "fishAndSeafood"),
            ("00000000-0000-0000-0000-000000000013", "Гарниры", "sideDishes"),
            ("00000000-0000-0000-0000-000000000014", "Быстрые рецепты", "quickRecipes"),
            ("00000000-0000-0000-0000-000000000015", "Детские блюда", "childrenDishes"),
            ("00000000-0000-0000-0000-000000000016", "Праздничные блюда", "festiveDishes"),
        ]
        return data.compactMap { idString, title, icon in
            guard let id = UUID(uuidString: idString) else { return nil }
            return CategorySupabase(id: id, title: title, iconName: icon)
        }
    }
}

struct RecipeShortInfo: Decodable {
    let id: UUID
    let title: String
    let imagePath: String?
    let userId: UUID
    let readyInMinutes: Int?
    let profile: ProfileShort
    
    struct ProfileShort: Decodable {
        let username: String
        let avatarUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case avatarUrl = "avatar_url"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case imagePath = "image_path"
        case userId = "user_id"
        case readyInMinutes = "ready_in_minutes"
        case profile = "profiles"
    }
    
    // Вычисляемые свойства для удобства
    var authorId: UUID { userId }
    var authorName: String { profile.username }
    var authorAvatarPath: String? { profile.avatarUrl }
}

struct RecipeInteraction: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let userId: UUID
    var rating: Int?          // Оценка от 1 до 5 (nil если не оценено)
    var comment: String?      // Комментарий (опционально)
    var photos: [String]?     // Пути к фотографиям в Storage
    var isFavorite: Bool      // В избранном или нет
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case userId = "user_id"
        case rating
        case comment
        case photos = "photo_paths"
        case isFavorite = "is_favorite"
        case createdAt = "created_at"
    }
}


struct Rating: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let userId: UUID
    let rating: Int
    let comment: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case userId = "user_id"
        case rating
        case comment
        case createdAt = "created_at"
    }
}

struct ReviewPhoto: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let userId: UUID
    let photoPath: String
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case userId = "user_id"
        case photoPath = "photo_path"
        case orderIndex = "order_index"
    }
}

struct FavoriteRecipe: Codable, Identifiable {
    let id: UUID
    let recipeId: UUID
    let userId: UUID
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct RecipeCategoryResponse: Decodable {
    let category: CategorySupabase?
}

struct RecipeFilters {
    let maxCookingTime: Int
    let categories: [String]
}

struct UniversalInstruction {
    let id: UUID
    let stepNumber: Int
    let description: String
    let imageData: Data?
    let imagePath: String?
    let orderIndex: Int?
    
    // Инициализатор из InstructionSupabase (онлайн)
    init(from supabase: InstructionSupabase) {
        self.id = supabase.id
        self.stepNumber = supabase.stepNumber
        self.description = supabase.description ?? ""
        self.imageData = nil
        self.imagePath = supabase.imagePath
        self.orderIndex = supabase.orderIndex
    }
    
    // Инициализатор из InstructionModel (офлайн)
    init(from realm: InstructionModel) {
        self.id = realm.id
        self.stepNumber = realm.stepNumber
        self.description = realm.descriptionText
        self.imageData = realm.imageData
        self.imagePath = nil
        self.orderIndex = realm.orderIndex
    }
    
    // Вспомогательное свойство
    var hasImage: Bool {
        return imageData != nil || imagePath != nil
    }
}
