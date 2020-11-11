//  Copyright © 2020 Andy Liang. All rights reserved.

import SwiftUI

struct AboutCell<Content : View> : View {
    let image: Image
    let title: String
    let accessory: Content

    init(image: Image, title: String, @ViewBuilder accessory: () -> Content) {
        self.image = image
        self.title = title
        self.accessory = accessory()
    }

    var body: some View {
        HStack {
            image
            Text(title)
                .foregroundColor(.primary)
                .font(.body)
            Spacer()
            accessory
                .font(.callout)
                .foregroundColor(Color(.placeholderText))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, isCatalyst ? 4 : 6)
        .frame(maxWidth: .infinity)
    }
}
