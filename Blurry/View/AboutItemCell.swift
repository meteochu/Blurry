//  Copyright © 2019 Andy Liang. All rights reserved.

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
        detailTextLabel?.textColor = .secondaryLabel
        addInteraction(UIPointerInteraction(delegate: self))
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

    func pointerInteraction(
        _ interaction: UIPointerInteraction, styleFor region: UIPointerRegion
    ) -> UIPointerStyle? {
        let targetedPreview = UITargetedPreview(view: self)
        return UIPointerStyle(effect: .automatic(targetedPreview))
    }
}
