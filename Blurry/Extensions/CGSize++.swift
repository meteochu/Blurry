//  Copyright © 2018 Andy Liang. All rights reserved.

import UIKit

extension CGSize {
    func aspectFill(ratio aspectRatio: CGSize) -> (size: CGSize, ratio: CGFloat) {
        var newSize = aspectRatio
        let mW = self.width / aspectRatio.width
        let mH = self.height / aspectRatio.height
        var ratio: CGFloat = 1.0
        if mW < mH {
            newSize.height = self.height / mW
            ratio = mW
        } else if mH < mW {
            newSize.width = self.width / mH
            ratio = mH
        }
        return (newSize, ratio)
    }    
}
