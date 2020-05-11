//
//  SceneDelegate.swift
//  Blurry
//
//  Created by Andy Liang on 2019-10-06.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate : UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions)
    {
        guard let windowScene = scene as? UIWindowScene,
            session.role == .windowApplication // don't permit external display support
        else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
#if targetEnvironment(macCatalyst)
        guard let bar = windowScene.titlebar else { return }
        bar.titleVisibility = .hidden
#endif
    }
}
