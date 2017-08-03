//
//  AppVersion.swift
//  Blurry
//
//  Created by Andy Liang on 8/2/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import Foundation

struct AppVersion {
    
    static var currentVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    static var bundleVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
}
