//
//  AppDelegate.swift
//  Blurry
//
//  Created by Andy Liang on 6/26/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        if #available(iOS 13.0, *) {
            // iOS 13 and above uses Scene setup
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = RootViewController()
            window?.makeKeyAndVisible()
        }
        return true
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .format)
        builder.replaceChildren(ofMenu: .about) { _ in
            let action = UIAction(title: "About Blurry") { _ in
                UIApplication.shared.requestSceneSessionActivation(
                    nil, userActivity: NSUserActivity(activityType: "about-page"),
                    options: nil, errorHandler: nil)
            }
            return [ action ]
        }
        let url = URL(string: "mailto:blurry@andyliang.me")!
        builder.replaceChildren(ofMenu: .help) { elements in
            let action = UIAction(title: "Contact Support") { action in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return [action]
        }
    }
}

@available(iOS 13.0, *) // iOS 13 Scene Support
extension AppDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if options.userActivities.isEmpty {
            let config = UISceneConfiguration(
                name: "Default Configuration", sessionRole: connectingSceneSession.role)
            config.delegateClass = SceneDelegate.self
            return config
        } else {
            let config = UISceneConfiguration(
                name: "About Configuration", sessionRole: connectingSceneSession.role)
            config.delegateClass = AboutSceneDelegate.self
            return config
        }
    }
}
