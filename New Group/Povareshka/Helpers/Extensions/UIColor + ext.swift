//
//  UIColor + ext.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 26.08.2024.
//

import UIKit

extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat? = 1.0) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: alpha ?? 1.0)
    }
}


extension UIColor {
    
    static let neutral100 = UIColor(red: 24/255, green: 24/255, blue: 24/255, alpha: 255/255)
    static let neutral90 = UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 255/255)
    static let neutral80 = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 255/255)
    static let neutral70 = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 255/255)
    static let neutral60 = UIColor(red: 121/255, green: 121/255, blue: 121/255, alpha: 255/255)
    static let neutral50 = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 255/255)
    static let neutral40 = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 255/255)
    static let neutral30 = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 255/255)
    static let neutral20 = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 255/255)
    static let neutral10 = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 255/255)
    static let neutral0 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 255/255)
    
}

