//  Copyright © 2020 Andy Liang. All rights reserved.

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Spacer()
            AboutHeaderView()
            Spacer().frame(height: 16)
            Text("CREATED BY")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Group {
                Button {
                    let twitterUrl = URL(string: "https://twitter.com/meteochu")!
                    UIApplication.shared.open(twitterUrl, options: [:], completionHandler: nil)
                } label: {
                    AboutCell(image: Image("Twitter"), title: "Andy Liang") {
                        Text("@meteochu")
                            .font(.callout)
                    }
                }

            }.background(Color(.secondarySystemGroupedBackground).cornerRadius(8))
            Spacer().frame(height: 16)
            VStack(spacing: 0) {
                Button {
                    let appstoreUrl = URL(string: "https://apps.apple.com/app/id1254612844?action=write-review")!
                    UIApplication.shared.open(appstoreUrl, options: [:], completionHandler: nil)
                } label: {
                    AboutCell(image: Image("Rate"), title: "Review Blurry") {
                        Image(systemName: "chevron.forward")
                    }
                }
                Divider()
                MailComposerButton(message: .contactInfo) {
                    AboutCell(image: Image("Contact"), title: "Contact Support") {
                        Image(systemName: "chevron.forward")
                    }
                }
                Divider()
                NavigationLink(destination: AcknowledgementView()) {
                    AboutCell(image: Image("Acknowledgements"), title: "Open Soure Licenses") {
                        Image(systemName: "chevron.forward")
                    }
                }
            }.background(Color(.secondarySystemGroupedBackground).cornerRadius(8))
            Text("Blurry \(Bundle.main.marketingVersion) (\(Bundle.main.bundleVersion))")
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(ProcessInfo.processInfo.isMacCatalystApp)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .previewLayout(.fixed(width: 320, height: 480))
    }
}
