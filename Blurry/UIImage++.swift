//
//  UIImage++.swift
//  Blurry
//
//  Created by Andy Liang on 6/30/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit

extension UIImage {
    
    func applying(style: BlurStyle, with radius: CGFloat) -> UIImage {
        switch style {
        case .dark:
            return UIImageEffects.imageByApplyingDarkEffect(to: self, withRadius: radius)
        case .light:
            return  UIImageEffects.imageByApplyingLightEffect(to: self, withRadius: radius)
        case .tintColor(let color):
            return UIImageEffects.imageByApplyingBlur(to: self, withRadius: radius, tintColor: color,
                                                      saturationDeltaFactor: -1, maskImage: nil)
        }
    }
    
    func scaled(to newSize: CGSize) -> UIImage {
        let renderFormat = UIGraphicsImageRendererFormat.default()
        renderFormat.opaque = false
        return UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat).image { context in
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        }
    }
    
}
