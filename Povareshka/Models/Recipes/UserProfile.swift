//
//  Profile.swift
//  Povareshka
//
//  Created by user on 01.06.2025.
//

import Foundation

// MARK: - Модель для обновления профиля
struct UserProfile: Codable, Identifiable {
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

// ShortInfoUser
struct UserProfileShort: Codable {
    let id: UUID
    let username: String?
    let avatarPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarPath = "avatar_url"
    }
}
