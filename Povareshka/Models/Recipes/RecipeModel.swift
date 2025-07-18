//
//  RecipeModel.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import Foundation
import RealmSwift

class RecipeModel: Object {
    @Persisted var title: String
    @Persisted var describe: String
    @Persisted var image: Data?
    @Persisted var ingredients: List<IngredientModel>
    @Persisted var readyInMinutes: String
    @Persisted var servings: Int
    @Persisted var instructions: List<InstructionModel>
}

class IngredientModel: Object {
    @Persisted var name: String
    @Persisted var amount: String
}

class InstructionModel: Object {
    @Persisted var number: Int
    @Persisted var image: Data?
    @Persisted var describe: String?
}
