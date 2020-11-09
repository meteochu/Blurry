//  Copyright © 2019 Andy Liang. All rights reserved.

import Foundation

extension Bundle {
    var marketingVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    var bundleVersion: String {
        object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
}
