//
//  SapobaseManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 17.04.2025.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // Replace these with your Supabase project URL and anon key
        let supabaseURL = "https://ixedhtnqygtzezlgpgyg.supabase.co"
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4ZWRodG5xeWd0emV6bGdwZ3lnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ3NDAyNjEsImV4cCI6MjA2MDMxNjI2MX0.SBzYsv_l0zQmLeroGOL38dik8hzjS0K9XK7MA27soVA"
        
        client = SupabaseClient(
            supabaseURL: URL(string: supabaseURL)!,
            supabaseKey: supabaseKey
        )
    }
}
