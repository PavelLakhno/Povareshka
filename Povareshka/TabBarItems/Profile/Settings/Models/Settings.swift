//
//  Settings.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 12.03.2025.
//

struct SettingsSection {
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem {
    let title: String
    let icon: String
    let type: SettingsItemType
}

enum SettingsItemType {
    case navigation(String?)
    case toggle(Bool)
    case info(String)
    case action
}
