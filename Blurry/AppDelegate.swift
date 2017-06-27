//
//  AppDelegate.swift
//  Blurry
//
//  Created by Andy Liang on 6/26/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let attributes: [String: Any] = [NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: 12, weight: .bold),
                                     NSAttributedStringKey.kern.rawValue: 2.0]
    UISegmentedControl.appearance().setTitleTextAttributes(attributes, for: .normal)
    return true
  }

}
