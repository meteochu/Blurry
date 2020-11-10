//  Copyright © 2020 Andy Liang. All rights reserved.

import SwiftUI
import MessageUI

struct MailComposerButton<Content: View> : View {
    let message: Message
    let content: Content
    @State var isPresented: Bool = false

    init(message: Message, @ViewBuilder content: () -> Content) {
        self.message = message
        self.content = content()
    }

    var body: some View {
        Button {
            #if targetEnvironment(macCatalyst)
            UIApplication.shared.open(message.mailToUrl, options: [:], completionHandler: nil)
            #else
            if MFMailComposeViewController.canSendMail() {
                isPresented = true
            } else {
                UIApplication.shared.open(message.mailToUrl, options: [:], completionHandler: nil)
            }
            #endif
        } label: {
            content
        }.sheet(isPresented: $isPresented) {
            isPresented = false
        } content: {
            MailComposerView(message).edgesIgnoringSafeArea(.all)
        }
    }
}
