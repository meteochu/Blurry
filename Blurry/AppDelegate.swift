//  Copyright © 2017 Andy Liang. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        #if targetEnvironment(macCatalyst)
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
        #else // iOS only
        let config = UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
        #endif
    }

#if targetEnvironment(macCatalyst)
    @objc func orderFrontStandardAboutPanel(_ sender: Any?) {
        UIApplication.shared.requestSceneSessionActivation(
            nil, userActivity: NSUserActivity(activityType: "about-page"),
            options: nil, errorHandler: nil)
    }

    @objc func showHelp(_ sender: Any?) {
        let url = URL(string: "mailto:blurry@andyliang.me")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
#endif
}
