//
//  SapobaseManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 17.04.2025.
//

import Foundation
import Supabase

enum Bucket {
    static let avatars = "avatars"
    static let recipes = "recipes"
    static let reviews = "reviews"
}

@MainActor
final class SupabaseManager: Sendable {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    private init() {
        // Проверяем, что URL валидный
        
        guard let url = URL(string: Config.supabaseUrl) else {
            fatalError("❌ Invalid Supabase URL: \(Config.supabaseUrl)")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.supabaseKey
        )
        
        print("✅ SupabaseManager initialized with URL: \(Config.supabaseUrl)")
    }
    
    func getCurrentUserId() async throws -> UUID? {
        let session = try await client.auth.session
        return UUID(uuidString: session.user.id.uuidString.lowercased())
    }
}

    

