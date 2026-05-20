//
//  AppImages.swift
//  Povareshka
//
//  Created by user on 24.09.2025.
//

import UIKit

enum AppImages {
    enum TabBar {
        static let mainview = UIImage(systemName: "fork.knife")
        static let shop = UIImage(systemName: "cart.fill")
        static let search = UIImage(systemName: "magnifyingglass")
        static let profile = UIImage(systemName: "person.fill")
    }
    
    enum Background {
        static let auth = UIImage(named: "Start_View_background")
        static let reg = UIImage(named: "Registration_View_background")
        static let meet = UIImage(named: "Auth_View_background")
    }
    
    enum Icons {
        static let add = UIImage(systemName: "plus")
        static let back = UIImage(systemName: "chevron.left")
        static let forward = UIImage(systemName: "chevron.right")
        static let addFill = UIImage(systemName: "plus.circle.fill")
        static let okFill = UIImage(systemName: "checkmark.circle.fill")
        static let trash = UIImage(systemName: "trash")
        static let avatar = UIImage(systemName: "person.circle")
        static let cart = UIImage(systemName: "cart")
        static let cameraMain = UIImage(systemName: "camera")
        static let edit = UIImage(systemName: "pencil")
        static let profile = UIImage(systemName: "person.circle.fill")
        static let cancel = UIImage(systemName: "multiply.circle.fill")
        static let deleteX = UIImage(systemName: "xmark")
        static let deleteFill = UIImage(systemName: "xmark.circle.fill")
        static let slider = UIImage(systemName: "slider.horizontal.3")

        static let level = UIImage(systemName: "cellularbars")
        static let clockFill = UIImage(systemName: "clock.fill")
        static let clockEmpty = UIImage(systemName: "clock")
        static let persons = UIImage(systemName: "person.2.fill")

        static let starEmpty = UIImage(systemName: "star")
        static let starFilled = UIImage(systemName: "star.fill")

        static let table = UIImage(systemName: "list.bullet")
        static let collection = UIImage(systemName: "square.grid.2x2")

        static let fork = UIImage(systemName: "fork.knife")
        static let heart = UIImage(systemName: "heart.fill")
        static let heartOutline = UIImage(systemName: "heart")

        static let book = UIImage(systemName: "book.closed")
        static let favorite = UIImage(systemName: "bookmark.fill")
        static let wifi = UIImage(systemName: "wifi.slash")

        // Profile menu
        static let saved = UIImage(systemName: "arrow.down.to.line.circle")
        static let gear = UIImage(systemName: "gearshape")
        static let helpCircle = UIImage(systemName: "questionmark.circle")
        static let info = UIImage(systemName: "info.circle")
        static let signOut = UIImage(systemName: "rectangle.portrait.and.arrow.right")

        // Settings
        static let globe = UIImage(systemName: "globe")
        static let bell = UIImage(systemName: "bell")
        static let moon = UIImage(systemName: "moon")
        static let lock = UIImage(systemName: "lock")

        // About features
        static let personBadgePlus = UIImage(systemName: "person.badge.plus")

        // Shopping cell
        static let checkbox = UIImage(systemName: "square")
        static let checkboxFill = UIImage(systemName: "checkmark.square.fill")
    }
}
