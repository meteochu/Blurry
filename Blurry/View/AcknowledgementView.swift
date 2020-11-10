//  Copyright © 2020 Andy Liang. All rights reserved.

import SwiftUI

struct AcknowledgementView : View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Text(textContent)
                .font(.footnote)
                .padding()
                .navigationBarHidden(ProcessInfo.processInfo.isMacCatalystApp)
        }
    }

    private var textContent: String {
        guard let filePath = Bundle.main.path(forResource: "Acknowledgement", ofType: "txt"),
              let content = try? String(contentsOfFile: filePath)
        else { return "Acknowledgements" }
        return content
    }
}
