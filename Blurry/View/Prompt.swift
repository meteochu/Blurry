//  Copyright © 2019 Andy Liang. All rights reserved.

import UIKit

struct Prompt {
    private struct Action {
        let title: String
        let action: () -> Void

        var alertAction: UIAlertAction {
            UIAlertAction(title: title, style: .default) { _ in self.action() }
        }
    }

    private let title: String?
    private var actions: [Action] = []
    private unowned let source: UIView

    var alertController: UIAlertController {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = source
            popover.sourceRect = source.bounds
            popover.permittedArrowDirections = [.up, .down]
        }
        actions.map { $0.alertAction }.forEach { alertController.addAction($0) }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertController
    }

    init(title: String? = nil, source: UIView) {
        self.title = title
        self.source = source
    }

    mutating func add(title: String, action: @escaping () -> Void) {
        let action = Action(title: title, action: action)
        actions.append(action)
    }
}
