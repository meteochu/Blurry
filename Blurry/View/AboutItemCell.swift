//
//  AboutItemCell.swift
//  Blurry
//
//  Created by Andy Liang on 2019-10-07.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit

struct AboutSection {
    var title: String? = nil
    var items: [AboutItem]
}

struct AboutItem {
    let title: String
    var detail: String? = nil
    let image: UIImage?
    var accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator
    let action: () -> Void
}

class AboutItemCell : UITableViewCell, UIPointerInteractionDelegate {
    static let reuseId = "AboutItemCell.reuseId"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        if #available(iOS 13.0, *) {
            detailTextLabel?.textColor = .secondaryLabel
        } else {
            textLabel?.textColor = .white
            detailTextLabel?.textColor = .lightText
            backgroundColor = UIColor(named: "Background")
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            selectedBackgroundView = backgroundView
        }

        if #available(iOS 13.4, *) {
            addInteraction(UIPointerInteraction(delegate: self))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var item: AboutItem? {
        didSet {
            guard let item = item else { return }
            textLabel?.text = item.title
            detailTextLabel?.text = item.detail
            imageView?.image = item.image
            accessoryType = item.accessoryType
        }
    }

    @available(iOS 13.4, *)
    func pointerInteraction(
        _ interaction: UIPointerInteraction, styleFor region: UIPointerRegion
    ) -> UIPointerStyle? {
        let targetedPreview = UITargetedPreview(view: self)
        return UIPointerStyle(effect: .automatic(targetedPreview))
    }
}
