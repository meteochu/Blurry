//  Copyright © 2020 Andy Liang. All rights reserved.

import UIKit

protocol CustomPaletteViewDelegate : class {
    func paletteViewDidSelectColor(_ color: UIColor, saturation: CGFloat, in view: CustomPaletteView)
}

class CustomPaletteView : UIView {
    weak var delegate: CustomPaletteViewDelegate?

    private(set) var currentColor: UIColor = UIColor.systemBlue.withAlphaComponent(0.5) {
        didSet { updateDelegate() }
    }

    private(set)  var currentSaturationValue: CGFloat = -1 {
        didSet { updateDelegate() }
    }

    private func updateDelegate() {
        delegate?.paletteViewDidSelectColor(currentColor, saturation: currentSaturationValue, in: self)
    }

    var labelColor: UIColor = .label {
        didSet {
            colorLabel.textColor = labelColor
            sliderLabel.textColor = labelColor
        }
    }

    private let colorLabel = UILabel()
    private let sliderLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        colorLabel.text = "Tint Color"
        colorLabel.font = .preferredFont(forTextStyle: .headline)

        sliderLabel.text = "Saturation (\(NumberFormatter.localizedString(from: currentSaturationValue as NSNumber, number: .decimal)))"
        sliderLabel.font = .preferredFont(forTextStyle: .headline)

        let colorWell = UIColorWell(frame: .zero, primaryAction: UIAction { [weak self] action in
            guard let colour = (action.sender as? UIColorWell)?.selectedColor else { return }
            self?.currentColor = colour
        })
        colorWell.selectedColor = currentColor
        colorWell.supportsAlpha = true

        let slider = UISlider(frame: .zero, primaryAction: UIAction { [weak self] action in
            guard let value = (action.sender as? UISlider)?.value else { return }
            let formattedValue = NumberFormatter.localizedString(from: value as NSNumber, number: .decimal)
            self?.sliderLabel.text = "Saturation (\(formattedValue))"
            guard let existing = self?.currentSaturationValue, abs(CGFloat(value) - existing) >= 0.20 else { return }
            self?.currentSaturationValue = CGFloat(value)
        })
        slider.minimumValue = -5.0
        slider.maximumValue = 5.0

        let contentView = UIStackView(arrangedSubviews: [ colorLabel, colorWell, sliderLabel, slider ])
        contentView.axis = .vertical
        contentView.spacing = 8
        contentView.setCustomSpacing(16, after: colorWell)

        addSubviewWithAutoLayout(contentView)
        layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])

        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
