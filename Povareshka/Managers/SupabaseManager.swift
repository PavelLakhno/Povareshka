//
//  SapobaseManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 17.04.2025.
//

import Foundation
import Supabase


final class SupabaseManager: Sendable {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Resources.Auth.supabaseUrl)!,
            supabaseKey: Resources.Auth.supabaseKey,
        )
    }
    
}

    

