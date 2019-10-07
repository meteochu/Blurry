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

    var shouldDisplayPicker: Bool {
        switch self {
        case .tintColor: return true
        default: return false
        }
    }

    static var allTitles: [String] {
        let titles = ["Dark", "Light", "Custom"]
        if #available(iOS 13.0, *) {
            return titles
        } else {
            return titles.map { $0.uppercased() }
        }
    }
}
