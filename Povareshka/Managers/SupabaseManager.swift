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

final class SupabaseManager: Sendable {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Resources.Auth.supabaseUrl)!,
            supabaseKey: Resources.Auth.supabaseKey
        )
    }
    
    func getCurrentUserId() async throws -> UUID? {
        let session = try await client.auth.session
        return UUID(uuidString: session.user.id.uuidString.lowercased())
    }
}

    

