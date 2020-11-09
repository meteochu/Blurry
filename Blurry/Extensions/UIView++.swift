//  Copyright © 2019 Andy Liang. All rights reserved.

import UIKit

extension UIView {
    func addSubviewWithAutoLayout(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }
}

extension NSLayoutConstraint {
    @discardableResult
    func atPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
