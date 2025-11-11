//
//  StorageManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import UIKit
import RealmSwift

@MainActor
class StorageManager {
    static let shared = StorageManager()
    private let realm: Realm

    private init() {
            let config = Realm.Configuration(
                schemaVersion: 3,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 3 {
                        print("Миграция Realm с версии \(oldSchemaVersion) на версию 3")
                        
                        // Миграция для тегов
                        migration.enumerateObjects(ofType: RecipeModel.className()) { oldObject, newObject in
                            // Конвертируем старые теги (List<String>) в новые (List<TagRealm>)
                            if let oldTags = oldObject?["tags"] as? List<DynamicObject> {
                                var newTags: [TagRealm] = []
                                
                                for tag in oldTags {
                                    if let tagString = tag["string"] as? String {
                                        let newTag = TagRealm(value: tagString)
                                        newTags.append(newTag)
                                    }
                                }
                                
                                // Сохраняем новые теги
                                newObject?["tags"] = newTags
                            }
                        }
                    }
                }
            )
            
            do {
                self.realm = try Realm(configuration: config)
                print("Realm database location: \(realm.configuration.fileURL?.path ?? "Unknown")")
            } catch {
                fatalError("Failed to initialize Realm: \(error)")
            }
        }
    // MARK: - Recipe Operations

    func saveRecipe(_ recipeDetails: RecipeDetailsResponse, imageData: Data?, instructionImages: [UUID: Data]) -> Bool {
        do {
            let recipeModel = RecipeModel(from: recipeDetails, imageData: imageData)
            
            // Добавляем изображения к инструкциям
            for instruction in recipeModel.instructions {
                if let imageData = instructionImages[instruction.id] {
                    instruction.imageData = imageData
                }
            }
            
            try realm.write {
                realm.add(recipeModel, update: .modified)
            }
            return true
        } catch {
            print("Error saving recipe to Realm: \(error)")
            return false
        }
    }
    
    func isRecipeSaved(_ recipeId: UUID) -> Bool {
        return realm.object(ofType: RecipeModel.self, forPrimaryKey: recipeId) != nil
    }
    
    func getSavedRecipe(_ recipeId: UUID) -> RecipeModel? {
        return realm.object(ofType: RecipeModel.self, forPrimaryKey: recipeId)
    }
    
    func getAllSavedRecipes() -> Results<RecipeModel> {
        return realm.objects(RecipeModel.self).sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    func deleteRecipe(_ recipeId: UUID) -> Bool {
        guard let recipe = getSavedRecipe(recipeId) else { return false }
        
        do {
            try realm.write {
                // Удаляем все связанные объекты перед удалением рецепта
                realm.delete(recipe.ingredients)
                realm.delete(recipe.instructions)
                realm.delete(recipe.tags)
                realm.delete(recipe.categories)
                
                realm.delete(recipe)
            }
            return true
        } catch {
            print("Error deleting recipe from Realm: \(error)")
            return false
        }
    }
    
    func toggleSaveRecipe(_ recipeDetails: RecipeDetailsResponse, imageData: Data?, instructionImages: [UUID: Data]) -> Bool {
        let recipeId = recipeDetails.recipe.id
        
        if isRecipeSaved(recipeId) {
            return deleteRecipe(recipeId)
        } else {
            return saveRecipe(recipeDetails, imageData: imageData, instructionImages: instructionImages)
        }
    }
    
    // MARK: - Image Operations
    
    func saveInstructionImage(_ imageData: Data?, for instructionId: UUID) {
        guard let imageData = imageData,
              let instruction = realm.object(ofType: InstructionModel.self, forPrimaryKey: instructionId) else { return }
        
        do {
            try realm.write {
                instruction.imageData = imageData
            }
        } catch {
            print("Error saving instruction image: \(error)")
        }
    }
}
