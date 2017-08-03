//
//  AboutTableViewController.swift
//  Blurry
//
//  Created by Andy Liang on 8/2/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit
import MessageUI

class AboutTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.versionLabel.text = "Blurry \(AppVersion.currentVersion) (\(AppVersion.bundleVersion))"
        if let controller = self.popoverPresentationController {
            controller.backgroundColor = self.view.backgroundColor
        }
    }
    
    @IBAction func didSelectDoneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            let twitterUrl = URL(string: "https://twitter.com/meteochu")!
            UIApplication.shared.open(twitterUrl, options: [:], completionHandler: nil)
        case (1, 0):
            let itunesUrl = URL(string: "https://itunes.apple.com/us/app/blurry/id1254612844?ls=1&mt=8&action=write-review")!
            UIApplication.shared.open(itunesUrl, options: [:], completionHandler: nil)
        case (1, 1):
            if MFMailComposeViewController.canSendMail() {
                let composeView = MFMailComposeViewController()
                composeView.setToRecipients(["blurry@andyliang.me"])
                composeView.setSubject("Blurry App")
                composeView.mailComposeDelegate = self
                self.present(composeView, animated: true, completion: nil)
            } else {
                let controller = UIAlertController(title: "No Mail Client", message: "It seems like you do not have the system mail app. You can stil contact support by emailing blurry@andyliang.me", preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
