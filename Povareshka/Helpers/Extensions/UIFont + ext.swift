//
//  UIFont + ext.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 29.08.2024.
//

import UIKit

extension UIFont {
    static func helveticalLight(withSize size: CGFloat) -> UIFont {
        UIFont.init(name: "Helvetica-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func helveticalRegular(withSize size: CGFloat) -> UIFont {
        UIFont.init(name: "Helvetica", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func helveticalBold(withSize size: CGFloat) -> UIFont {
        UIFont.init(name: "Helvetica-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
