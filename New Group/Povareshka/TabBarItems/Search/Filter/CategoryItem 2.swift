//
//  CategoryItem.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 14.03.2025.
//

struct CategoryItem {
    let title: String
    let imageUrl: String
    
    static let mockCategories: [CategoryItem] = [
        CategoryItem(title: "Первые блюда", imageUrl: "first_course"),
        CategoryItem(title: "Вторые блюда", imageUrl: "second_course"),
        CategoryItem(title: "Рыбные блюда", imageUrl: "fish"),
        CategoryItem(title: "Напитки", imageUrl: "drinks"),
        CategoryItem(title: "Салаты", imageUrl: "salads"),
        CategoryItem(title: "Десерты", imageUrl: "desserts")
    ]
}
