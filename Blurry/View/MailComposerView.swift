//  Copyright © 2020 Andy Liang. All rights reserved.

import MessageUI
import SwiftUI

struct Message {
    var recipients: [String] = []
    var subject: String = ""
    var body: String = ""

    var mailToUrl: URL {
        let content = "mailto:\(recipients.joined(separator: ";"))"
            + "?subject=\(subject)"
            + "&body=\(body.replacingOccurrences(of: "\n", with: "%0D%0A"))"
        return URL(string: content.replacingOccurrences(of: " ", with: "%20"))!
    }
}

extension Message {
    static let contactInfo = Message(
        recipients: ["blurry@andyliang.me"],
        subject: "[Feedback] Blurry \(Bundle.main.marketingVersion)",
        body: """



        ==================================
        App: \(Bundle.main.bundleIdentifier!)
        Version: \(Bundle.main.marketingVersion) (Build \(Bundle.main.bundleVersion))
        OS: \(ProcessInfo.processInfo.isMacCatalystApp ? "macOS" : "iOS") \(ProcessInfo.processInfo.operatingSystemVersionString)
        Locale: \(Locale.current.localizedString(forIdentifier: Locale.current.identifier) ?? Locale.current.identifier)
        ==================================
        """)
}


struct MailComposerView : UIViewControllerRepresentable {
    let message: Message

    init(_ message: Message) {
        self.message = message
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        viewController.mailComposeDelegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ viewController: MFMailComposeViewController, context: Context) {
        viewController.setSubject(message.subject)
        viewController.setToRecipients(message.recipients)
        viewController.setMessageBody(message.body, isHTML: false)
    }

    // MARK: Coordinator

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator : NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
