//
//  RatingSorterManager.swift
//  Povareshka
//
//  Created by user on 14.08.2025.
//

import UIKit

// MARK: - RatingsSorter
struct RatingsSorter {
    static func sorted(ratings: [Rating], by option: ReviewsViewController.SortOption, photos: [ReviewPhoto]) -> [Rating] {
        switch option {
        case .dateDesc: return ratings.sorted { $0.createdAt > $1.createdAt }
        case .dateAsc: return ratings.sorted { $0.createdAt < $1.createdAt }
        case .ratingDesc: return ratings.sorted { $0.rating > $1.rating }
        case .ratingAsc: return ratings.sorted { $0.rating < $1.rating }
        case .withPhotos:
            let ratingsWithPhotos = Set(photos.map { $0.userId })
            return ratings.filter { ratingsWithPhotos.contains($0.userId) }
        case .withComments:
            return ratings.filter { $0.comment?.isEmpty == false }
        }
    }
    
    static func title(for option: ReviewsViewController.SortOption) -> String {
        switch option {
        case .dateDesc: return "Сортировка: По дате (новые)"
        case .dateAsc: return "Сортировка: По дате (старые)"
        case .ratingDesc: return "Сортировка: По рейтингу (высокий)"
        case .ratingAsc: return "Сортировка: По рейтингу (низкий)"
        case .withPhotos: return "Сортировка: С фото"
        case .withComments: return "Сортировка: С комментариями"
        }
    }
    
    @MainActor
    static func sortAlertController(
        currentOption: ReviewsViewController.SortOption,
        completion: @escaping (ReviewsViewController.SortOption) -> Void
    ) -> UIAlertController {
        let alert = UIAlertController(title: "Сортировка отзывов", message: nil, preferredStyle: .actionSheet)
        
        let options: [ReviewsViewController.SortOption] = [.dateDesc, .dateAsc, .ratingDesc, .ratingAsc, .withPhotos, .withComments]
        
        options.forEach { option in
            let action = UIAlertAction(title: title(for: option), style: .default) { _ in
                completion(option)
            }
            action.setValue(option == currentOption, forKey: "checked")
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        return alert
    }
}
