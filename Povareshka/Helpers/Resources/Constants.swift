//
//  Constant.swift
//  Povareshka
//
//  Created by user on 24.09.2025.
//

import UIKit

enum Constants {
    static let imageAspectRatio: CGFloat = 1.5
    static let categoryCellSize = CGSize(width: 100, height: 100)
    static let trendingCellSize = CGSize(width: 320, height: 220)
    
    static let insentsRightLeftSides = UIEdgeInsets(top: 0, left: Constants.paddingMedium,
                                              bottom: 0, right: Constants.paddingMedium)
    static let insetsAllSides = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    static let cornerRadiusBig: CGFloat = 20
    static let cornerRadiusMedium: CGFloat = 15
    static let cornerRadiusSmall: CGFloat = 10
    
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingWidth: CGFloat = 20

    static let photosSectionHeight: CGFloat = 140
    static let photoCollectionHeight: CGFloat = 100
    static let heightStandart: CGFloat = 100
    static let buttonHeight: CGFloat = 44
    static let height: CGFloat = 44
    
    static let iconCellSizeBig = CGSize(width: 40, height: 40)
    static let iconCellSizeMedium = CGSize(width: 30, height: 30)
    static let iconCellSizeSmall = CGSize(width: 20, height: 20)
    
    static let photoCellSizeMedium = CGSize(width: 80, height: 80)
    static let photoCellSizeBig = CGSize(width: 100, height: 100)
    
    static let tagSizeButton = CGSize(width: 100, height: 40)

    static let spacingSmall: CGFloat = 4
    static let spacingMedium: CGFloat = 8
    static let spacingBig: CGFloat = 16
}
