//
//  UIFont + ext.swift
//  Povareshka
//
//  Created by Pavel Lakhno on 29.08.2024.
//

import UIKit

extension UIFont {
    
    //Regular
    static func poppinsRegular(withSize size: CGFloat) -> UIFont? {
        UIFont.init(name: "Poppins-Regular", size: size)
    }
    
    //Bold
    static func poppinsBold(withSize size: CGFloat) -> UIFont? {
        UIFont.init(name: "Poppins-Bold", size: size)
    }
    
    //Helvetical
    static func helveticalLight(withSize size: CGFloat) -> UIFont? {
        UIFont.init(name: "Helvetica-Light", size: size)
    }
    
    static func helveticalRegular(withSize size: CGFloat) -> UIFont? {
        UIFont.init(name: "Helvetica", size: size)
    }
    
    //Bold
    static func helveticalBold(withSize size: CGFloat) -> UIFont? {
        UIFont.init(name: "Helvetica-Bold", size: size)
    }
}
