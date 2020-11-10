//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

class NavigationController : UINavigationController {
    @objc public func popLastViewController() {
        guard viewControllers.count > 1 else { return }
        popViewController(animated: true)
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard action == #selector(popLastViewController) else {
            return super.canPerformAction(action, withSender: sender)
        }
        return viewControllers.count > 1
    }
}
