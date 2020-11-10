//  Copyright © 2020 Andy Liang. All rights reserved.

import SwiftUI

struct AboutHeaderView : View {
    var body: some View {
        VStack {
            Image("MacIcon")
                .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
            Text("Blurry")
                .bold()
                .font(.title)
            Text("Quick and Easy Image Blurring")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
