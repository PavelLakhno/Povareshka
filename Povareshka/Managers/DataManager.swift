//
//  DataManager.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 19.03.2025.
//

import UIKit
import Foundation
import RealmSwift


class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void) {
        // ингридиенты
        let ingredient1 = IngredientModel()
        ingredient1.name = "Яица"
        ingredient1.amount = "2 шт"
        
        let ingredient2 = IngredientModel()
        ingredient2.name = "Масло рафинированное"
        ingredient2.amount = "1 ч/л"
        
        let ingredient3 = IngredientModel()
        ingredient3.name = "Вода"
        ingredient3.amount = "50 мл"
        
        let ingredient4 = IngredientModel()
        ingredient4.name = "Соль"
        ingredient4.amount = "по вкусу"
        
        let ingredient5 = IngredientModel()
        ingredient5.name = "Черный молотый перец"
        ingredient5.amount = "по вкусу"
        
        // шаги
        let step1 = InstructionModel()
        step1.number = 1
        step1.image = UIImage(named: "step1.png")?.pngData()
        step1.describe = "Помойте и обсушите яйца и помидоры. Томаты для подачи нарежьте на половинки."
        
        let step2 = InstructionModel()
        step2.number = 2
        step2.image = UIImage(named: "step2.png")?.pngData()
        step2.describe = "В сковородку с толстым дном влейте масло и поставьте ее на огонь. Яйца вбейте в миску. Посолите и поперчите их по вкусу. Слегка взбейте их вилкой или венчиком. Влейте в них воду комнатной температуры. Тщательно перемешайте."
        
        let step3 = InstructionModel()
        step3.number = 3
        step3.image = UIImage(named: "step3.png")?.pngData()
        step3.describe = "Вылейте яичную смесь в сковороду. Как только она начнет схватываться, перемешивайте ее лопаткой. Жарьте яйца таким образом 2-3 минуты, а затем уберите с огня."
        
        let step4 = InstructionModel()
        step4.number = 4
        step4.image = UIImage(named: "step4.png")?.pngData()
        step4.describe = "Подайте яичницу-болтунью с помидорами. При желании сверху можно добавить молотый перец или свежую зелень."
        
        // основной рецепт
        let recipe = RecipeModel()
        recipe.title = "Яичница-болтунья"
        recipe.describe = "Яичница-болтунья прекрасно подходит для быстрого завтрака. Тем более, что состоит это блюдо из простых ингредиентов. При желании можно дополнить его колбасой, помидорами или сыром. А чтобы завтрак получился полезнее, возьмите свежие домашние яйца с ярко-оранжевым желтком. Подавайте яичницу-болтунью с любыми свежими овощами или зеленью."
        recipe.image = UIImage(named: "step0.png")?.pngData()
        recipe.ingredients.insert(contentsOf: [ingredient1, ingredient2, ingredient3, ingredient4, ingredient5], at: 0)
        recipe.readyInMinutes = "15 мин"
        recipe.servings = 2
        recipe.instructions.insert(contentsOf: [step1, step2, step3, step4], at: 0)
        
        DispatchQueue.main.async {
            StorageManager.shared.save(recipe)
            completion()
        }
        
    }
}
