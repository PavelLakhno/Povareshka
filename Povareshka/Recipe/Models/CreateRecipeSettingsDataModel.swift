//
//  CreateRecipeSettingsDataModel.swift
//  RecipeAddApp
//
//  Created by Pavel Lakhno on 09.11.2024.
//

import Foundation

struct CreateRecipeSettingDataModel {
    let iconImageName : String
    let titleText : String
}

extension CreateRecipeSettingDataModel {
    static let prebuildData : [CreateRecipeSettingDataModel] = [
        .init(iconImageName: "Icons/Profile", titleText: "Порции"),
        .init(iconImageName: "Icons/Clock", titleText: "Время \nприготовления")
    ]
}
