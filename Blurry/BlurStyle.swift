//
//  BlurStyle.swift
//  Blurry
//
//  Created by Andy Liang on 6/30/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit

enum BlurStyle {
    case dark
    case light
    case tintColor(UIColor)
}

extension BlurStyle {
    
    var tintColor: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return UIColor(red: 0.15, green: 0.22, blue: 0.5, alpha: 1)
        case .tintColor:
            return .white
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .dark:
            return UIColor(red: 0.15, green: 0.22, blue: 0.5, alpha: 1)
        case .light:
            return UIColor(white: 0.9, alpha: 1)
        case .tintColor(let color):
            return color
        }
    }
    
}
