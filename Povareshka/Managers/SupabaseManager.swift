//
//  SapobaseManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 17.04.2025.
//

import Foundation
import Supabase


final class SupabaseManager {
    @MainActor static let shared = SupabaseManager()
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Resources.Auth.supabaseUrl)!,
            supabaseKey: Resources.Auth.supabaseKey,
        )
    }
    
}
    
// Модель для профиля пользователя
struct UserProfile: Encodable {
    let id: UUID
    let name: String
    let phone: String
    let gender: String
    let createdAt: Date
}
