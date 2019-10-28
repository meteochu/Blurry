//
//  AboutSceneDelegate.swift
//  Blurry
//
//  Created by Andy Liang on 2019-10-27.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
class AboutSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = scene as? UIWindowScene else { return }
        // 1. setup the size restrictions
        if let restrictions = windowScene.sizeRestrictions {
            restrictions.minimumSize = CGSize(width: 480, height: 640)
            restrictions.maximumSize = CGSize(width: 480, height: 768)
        }
        // 2. update the title bar
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
        }
        // 3. setup the window
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: AboutViewController())
        window?.makeKeyAndVisible()
    }
}
#endif
