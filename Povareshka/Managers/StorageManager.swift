//
//  StorageManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import Foundation
import RealmSwift

class StorageManager {
    static let shared = StorageManager()
    let realm = try! Realm()
    
    private init() {}
    
    func save(_ recipe: RecipeModel) {
        try! realm.write {
            realm.add(recipe)
        }
    }
    
    func saveData(_ recipe: String, completion:(RecipeModel) -> Void) {
        try! realm.write {
            let recipe = RecipeModel(value: [recipe])
            realm.add(recipe)
            completion(recipe)
        }
    }
}
