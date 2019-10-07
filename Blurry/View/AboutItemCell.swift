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

class AboutItemCell : UITableViewCell {
    static let reuseId = "AboutItemCell.reuseId"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        if #available(iOS 13.0, *) {
            detailTextLabel?.textColor = .secondaryLabel
        } else {
            detailTextLabel?.textColor = .lightText
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
}
