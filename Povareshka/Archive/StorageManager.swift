//
//  StorageManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

//import UIKit
//import RealmSwift

//@MainActor 
//class StorageManager {
//    static let shared = StorageManager()
//    let realm = try! Realm()
//    
//    private init() {}
//    
//    func save(_ recipe: RecipeModel) {
//        try! realm.write {
//            realm.add(recipe)
//        }
//    }
//    
//    func saveData(_ recipe: String, completion:(RecipeModel) -> Void) {
//        try! realm.write {
//            let recipe = RecipeModel(value: [recipe])
//            realm.add(recipe)
//            completion(recipe)
//        }
//    }
//    
//    func saveToRealm(
//        recipeId: UUID,
//        title: String,
//        image: UIImage?,
//        servings: Int?,
//        readyInMinutes: Int?,
//        ingredients: [Ingredient],
//        steps: [Instruction]
//    ) {
//        let recipeModel = RecipeModel()
////        recipeModel. = recipeId
//        recipeModel.title = title
//        recipeModel.image = image?.pngData()
//        recipeModel.readyInMinutes = readyInMinutes.map { "\($0) мин" } ?? ""
//        recipeModel.servings = servings ?? 0
//        
//        for ingredient in ingredients {
//            let ingredientModel = IngredientModel()
//            ingredientModel.name = ingredient.name
//            ingredientModel.amount = ingredient.amount
//            recipeModel.ingredients.append(ingredientModel)
//        }
//        
//        for step in steps {
//            let instructionModel = InstructionModel()
//            instructionModel.number = step.number
//            instructionModel.image = step.image
//            instructionModel.describe = step.describe
//            recipeModel.instructions.append(instructionModel)
//        }
//        
//        StorageManager.shared.save(recipeModel)
//    }
//}
