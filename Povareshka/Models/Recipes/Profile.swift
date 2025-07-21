//
//  Profile.swift
//  Povareshka
//
//  Created by user on 01.06.2025.
//

import Foundation

// MARK: - Модель для обновления профиля

struct Profile: Codable, Identifiable {
    let id: UUID
    let username: String?
    let fullName: String?
    let website: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case fullName = "full_name"
        case website
        case avatarURL = "avatar_url"
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
    let orderIndex: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case amount
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
//        case tag
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
//    var isSelected: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case iconName = "icon_name"
//        case isSelected
    }
    
    static func allCategories() -> [CategorySupabase] {
        return [
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                             title: "Завтраки", iconName: "breakfast"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                             title: "Основные блюда", iconName: "mainCourses"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                             title: "Супы", iconName: "soups"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                             title: "Салаты", iconName: "salads"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                             title: "Закуски", iconName: "appetizers"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
                             title: "Десерты", iconName: "desserts"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
                             title: "Выпечка", iconName: "pastries"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
                             title: "Напитки", iconName: "drinks"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
                             title: "Соусы и маринады", iconName: "saucesAndMarinades"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
                             title: "Паста и пицца", iconName: "pastaAndPizza"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
                             title: "Мясные блюда", iconName: "meatDishes"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
                             title: "Рыба и морепродукты", iconName: "fishAndSeafood"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
                             title: "Гарниры", iconName: "sideDishes"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!,
                             title: "Быстрые рецепты", iconName: "quickRecipes"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!,
                             title: "Детские блюда", iconName: "childrenDishes"),
            CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!,
                             title: "Праздничные блюда", iconName: "festiveDishes"),
        ]
    }
}

//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
//                 title: "Завтраки", iconName: "breakfast", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
//                 title: "Основные блюда", iconName: "mainCourses", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
//                 title: "Супы", iconName: "soups", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
//                 title: "Салаты", iconName: "salads", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
//                 title: "Закуски", iconName: "appetizers", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
//                 title: "Десерты", iconName: "desserts", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
//                 title: "Выпечка", iconName: "pastries", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
//                 title: "Напитки", iconName: "drinks", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
//                 title: "Соусы и маринады", iconName: "saucesAndMarinades", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
//                 title: "Паста и пицца", iconName: "pastaAndPizza", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
//                 title: "Мясные блюда", iconName: "meatDishes", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
//                 title: "Рыба и морепродукты", iconName: "fishAndSeafood", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
//                 title: "Гарниры", iconName: "sideDishes", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!,
//                 title: "Быстрые рецепты", iconName: "quickRecipes", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!,
//                 title: "Детские блюда", iconName: "childrenDishes", isSelected: false),
//CategorySupabase(id: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!,
//                 title: "Праздничные блюда", iconName: "festiveDishes", isSelected: false),

struct RecipeShortInfo: Decodable {
    let id: UUID
    let title: String
    let imagePath: String?
    let userId: UUID
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


// new added for RecipeRating
struct Rating: Codable {
    let id: UUID
    let recipeId: UUID
    let userId: UUID
    let rating: Int
    let comment: String?
}

struct RecipePhoto: Codable {
    let id: UUID
    let recipeId: UUID
    let userId: UUID
    let photoPath: String
    let orderIndex: Int
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



//struct RecipeShortInfo: Decodable {
//    let id: UUID
//    let title: String
//    let imagePath: String?
//    let authorId: UUID
//    let authorName: String
//    let authorAvatarPath: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, title
//        case imagePath = "image_path"
//        case authorId = "user_id"
//        case profile = "profiles"  // Ключ для вложенного объекта
//    }
//
//    enum ProfileKeys: String, CodingKey {
//        case username
//        case avatarUrl = "avatar_url"
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(UUID.self, forKey: .id)
//        title = try container.decode(String.self, forKey: .title)
//        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
//        authorId = try container.decode(UUID.self, forKey: .authorId)
//
//        // Декодируем вложенный объект профиля
//        let profileContainer = try container.nestedContainer(
//            keyedBy: ProfileKeys.self,
//            forKey: .profile
//        )
//        authorName = try profileContainer.decode(String.self, forKey: .username)
//        authorAvatarPath = try profileContainer.decodeIfPresent(String.self, forKey: .avatarUrl)
//    }
//}
