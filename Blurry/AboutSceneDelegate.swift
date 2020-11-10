//  Copyright © 2019 Andy Liang. All rights reserved.

import UIKit
import SwiftUI

#if targetEnvironment(macCatalyst)
class AboutSceneDelegate: UIResponder, UIWindowSceneDelegate, NSToolbarDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = scene as? UIWindowScene else { return }
        // 1. setup the size restrictions
        let maxSize = windowScene.sizeRestrictions!.maximumSize
        if let restrictions = windowScene.sizeRestrictions {
            restrictions.minimumSize = CGSize(width: 360, height: 512)
            restrictions.maximumSize = CGSize(width: 360, height: 512)
        }
        // 2. update the title bar
        let toolbar = NSToolbar(identifier: "About")
        toolbar.delegate = self
        windowScene.titlebar?.toolbarStyle = .unifiedCompact
        windowScene.titlebar?.toolbar = toolbar
        windowScene.title = "About Blurry"
        // 3. setup the window
        let rootViewController = NavigationController(rootViewController: UIHostingController(rootView: AboutView()))
        rootViewController.setNavigationBarHidden(true, animated: false)
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard !windowScene.windows.isEmpty else { return }
            windowScene.sizeRestrictions?.maximumSize = maxSize
        }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.back, .flexibleSpace]

    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .back:
            let item = NSToolbarItem(itemIdentifier: .back)
            item.image = UIImage(systemName: "chevron.backward")
            item.isBordered = true
            item.action = #selector(NavigationController.popLastViewController)
            item.isNavigational = true
            return item
        default:
            return nil
        }
    }
}

private extension NSToolbarItem.Identifier {
    static let back = NSToolbarItem.Identifier("Back")
}
#endif
