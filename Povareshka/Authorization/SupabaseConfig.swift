//
//  Config.swift
//  Povareshka
//
//  Created by user on 24.09.2025.
//

import Foundation

@MainActor
enum Config {
    private static let plist: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            fatalError("❌ Config.plist not found. Please make sure the file exists in the project.")
        }
        return dict
    }()
    
    static let supabaseUrl: String = {
        guard let url = plist["SUPABASE_URL"] as? String else {
            fatalError("❌ SUPABASE_URL not found in Config.plist")
        }
        return url
    }()
    
    static let supabaseKey: String = {
        guard let key = plist["SUPABASE_KEY"] as? String else {
            fatalError("❌ SUPABASE_KEY not found in Config.plist")
        }
        return key
    }()
    
    static let supabaseRedirect: String = {
        guard let redirect = plist["SUPABASE_REDIRECT"] as? String else {
            fatalError("❌ SUPABASE_REDIRECT not found in Config.plist")
        }
        return redirect
    }()
}
