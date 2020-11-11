//  Copyright © 2020 Andy Liang. All rights reserved.

import SwiftUI

let isCatalyst = ProcessInfo.processInfo.isMacCatalystApp

struct AboutView: View {
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 4) {
            #if targetEnvironment(macCatalyst)
            Spacer()
            #endif
            AboutHeaderView()
            Spacer().frame(height: 16)
            Text("OTHER APPS")
                .font(.footnote)
                .offset(x: 12)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Group {
                Button {
                    let appStoreUrl = URL(string: "https://apps.apple.com/app/sigma-planner/id1106938042")!
                    UIApplication.shared.open(appStoreUrl, options: [:], completionHandler: nil)
                } label: {
                    AboutCell(image: Image("SigmaPlanner"), title: "Sigma Planner") {
                        Image(systemName: "arrow.up.forward.app")
                    }
                }
                Spacer().frame(height: 8)
            }.background(cellContentBackground)


            Text("CREATED BY")
                .font(.footnote)
                .offset(x: 12)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Group {
                Button {
                    let twitterUrl = URL(string: "https://twitter.com/meteochu")!
                    UIApplication.shared.open(twitterUrl, options: [:], completionHandler: nil)
                } label: {
                    AboutCell(image: Image("Twitter"), title: "Andy Liang") {
                        Text("@meteochu")
                    }
                }
                Spacer().frame(height: 16)
            }.background(cellContentBackground)

            VStack(spacing: 0) {
                Button {
                    let appstoreUrl = URL(string: "https://apps.apple.com/app/id1254612844?action=write-review")!
                    UIApplication.shared.open(appstoreUrl, options: [:], completionHandler: nil)
                } label: {
                    AboutCell(image: Image("Rate"), title: "Review Blurry") {
                        Image(systemName: "chevron.forward")
                    }
                }
                Divider().padding(.leading, 16)
                MailComposerButton(message: .contactInfo) {
                    AboutCell(image: Image("Contact"), title: "Contact Support") {
                        Image(systemName: "chevron.forward")
                    }
                }
                Divider().padding(.leading, 16)
                NavigationLink(destination: AcknowledgementView()) {
                    AboutCell(image: Image("Acknowledgements"), title: "Open Source Licenses") {
                        Image(systemName: "chevron.forward")
                    }
                }
            }.background(cellContentBackground)
            Text("Blurry \(Bundle.main.marketingVersion) (\(Bundle.main.bundleVersion))")
                .font(.callout)
                .foregroundColor(.secondary)
            Spacer()
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(isCatalyst)
        .navigationTitle("About")
    }

    var cellContentBackground: some View {
        Color(.secondarySystemGroupedBackground)
            .cornerRadius(isCatalyst ? 10 : 13)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .previewLayout(.fixed(width: 375, height: 600))
    }
}
