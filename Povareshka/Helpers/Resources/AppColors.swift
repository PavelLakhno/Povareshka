//
//  AppColors.swift
//  Povareshka
//
//  Created by user on 24.09.2025.
//

import UIKit

enum AppColors {
    static let primaryOrange = UIColor(hexString: "#F8A362")

    static let gray100 = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hexString: "#1C1C1E") : UIColor(hexString: "#F1F1F1")
    }
    static let gray200 = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hexString: "#3A3A3C") : UIColor(hexString: "#D8D8D8")
    }
    static let gray400 = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hexString: "#636366") : UIColor(hexString: "#AEAEAE")
    }
    static let gray600 = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hexString: "#8E8E93") : UIColor(hexString: "#8A8A8A")
    }

    static let collectionViewBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hexString: "#3A3A3C") : .white
    }
}


