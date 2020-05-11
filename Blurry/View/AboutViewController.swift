//
//  AboutViewController.swift
//  Blurry
//
//  Created by Andy Liang on 2019-10-07.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UITableViewController {
    private var sections: [AboutSection] = []

    init() {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
#if !targetEnvironment(macCatalyst)
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close, target: self, action: #selector(didTapCloseButton))
#endif
        } else {
            super.init(style: .grouped)
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done, target: self, action: #selector(didTapCloseButton))
        }
        title = "About"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        let imageView = UIImageView(image: UIImage(named: "Icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowRadius = 3.0
        imageView.layer.shadowOpacity = 0.25
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        let titleLabel = UILabel()
        titleLabel.text = "Blurry"
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        let detailLabel = UILabel()
        detailLabel.text = "Quick and Easy Image Blurring"
        detailLabel.textAlignment = .center
        detailLabel.font = .preferredFont(forTextStyle: .body)
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, detailLabel])
        stackView.axis = .vertical
        stackView.setCustomSpacing(8, after: imageView)
        tableView.tableHeaderView = stackView
        stackView.frame.size = stackView.systemLayoutSizeFitting(tableView.bounds.size)

        let versionLabel = UILabel()
        versionLabel.textAlignment = .center
        versionLabel.font = .preferredFont(forTextStyle: .callout)
        versionLabel.text = "Blurry \(Bundle.main.marketingVersion) (\(Bundle.main.bundleVersion))"
        tableView.tableFooterView = versionLabel
        versionLabel.sizeToFit()

        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
            detailLabel.textColor = .secondaryLabel
            versionLabel.textColor = .secondaryLabel
        } else {
            titleLabel.textColor = .white
            detailLabel.textColor = .lightGray
            versionLabel.textColor = .lightGray
            tableView.separatorColor = UIColor(white: 0.15, alpha: 1.0)
            view.backgroundColor = UIColor(named: "Background")
            navigationController?.navigationBar.barStyle = .black
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(AboutItemCell.self, forCellReuseIdentifier: AboutItemCell.reuseId)
        sections = [
            AboutSection(title: "Created By", items: [
                AboutItem(title: "Andy Liang", detail: "@meteochu",
                          image: UIImage(named: "Twitter"), accessoryType: .none)
                {
                    let twitterUrl = URL(string: "https://twitter.com/meteochu")!
                    UIApplication.shared.open(twitterUrl, options: [:], completionHandler: nil)
                }
            ]),
            AboutSection(items: [
                AboutItem(title: "Review Blurry", image: UIImage(named: "Rate")) {
                    #if targetEnvironment(macCatalyst)
                    let appstoreUrl = URL(string: "https://apps.apple.com/app/id1482686361?action=write-review")!
                    #else
                    let appstoreUrl = URL(string: "https://apps.apple.com/app/id1254612844?action=write-review")!
                    #endif
                    UIApplication.shared.open(appstoreUrl, options: [:], completionHandler: nil)
                },
                AboutItem(title: "Contact Support", image: UIImage(named: "Contact")) { [unowned self] in
#if targetEnvironment(macCatalyst)
                    let url = URL(string: "mailto:blurry@andyliang.me")!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
#else
                    if MFMailComposeViewController.canSendMail() {
                        let composeView = MFMailComposeViewController()
                        composeView.setToRecipients(["blurry@andyliang.me"])
                        composeView.setSubject("Blurry App")
                        composeView.mailComposeDelegate = self
                        self.present(composeView, animated: true, completion: nil)
                    } else {
                        let controller = UIAlertController(title: "Mail Unavailable", message: "It seems like you either do not have the system mail app or have not set up any accounts in it. You can stil contact support by emailing blurry@andyliang.me", preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "Copy Email", style: .default, handler: { _ in
                            UIPasteboard.general.string = "blurry@andyliang.me"
                        }))
                        controller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self.present(controller, animated: true, completion: nil)
                    }
#endif
                },
                AboutItem(title: "Acknowledgements", image: UIImage(named: "Acknowledgements")) {
                    let viewController = AcknowledgementViewController()
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            ])
        ]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AboutItemCell.reuseId, for: indexPath) as! AboutItemCell
        cell.item = sections[indexPath.section].items[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].items[indexPath.row].action()
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension AboutViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}
