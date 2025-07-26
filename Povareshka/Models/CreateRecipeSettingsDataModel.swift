//
//  CreateRecipeSettingsDataModel.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 09.11.2024.
//

import Foundation
import UIKit

struct CreateRecipeSettingDataModel {
    let iconImageName : String
    let titleText : String
}

extension CreateRecipeSettingDataModel {
    static let prebuildData : [CreateRecipeSettingDataModel] = [
        .init(iconImageName: Resources.Images.Icons.persons, titleText: "Порции"),
        .init(iconImageName: Resources.Images.Icons.clockFill, titleText: "Время \nприготовления"),
        .init(iconImageName: Resources.Images.Icons.level, titleText: "Сложность")
    ]
}
