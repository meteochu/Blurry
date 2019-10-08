//
//  ColorPickerView.swift
//  Blurry
//
//  Created by Andy Liang on 2019-10-06.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit
import ChromaColorPicker

protocol ColorPickerDelegate : class {
    func colorPickerDidChooseColor(_ picker: ColorPickerView, color: UIColor)
}

class ColorPickerView : UIView, ChromaColorPickerDelegate {
    weak var delegate: ColorPickerDelegate?
    
    let alphaLabel = UILabel()
    var color: UIColor { currentColor.withAlphaComponent(currentAlpha) }

    private var currentColor: UIColor = .red {
        didSet { delegate?.colorPickerDidChooseColor(self, color: color) }
    }

    private var currentAlpha: CGFloat = 0.5 {
        didSet { delegate?.colorPickerDidChooseColor(self, color: color) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let colorPicker = ChromaColorPicker()
        colorPicker.hexLabel.textColor = .white
        colorPicker.stroke = 6
        colorPicker.delegate = self


        alphaLabel.text = "Alpha"
        alphaLabel.font = .preferredFont(forTextStyle: .headline)

        let slider = UISlider()
        slider.value = 0.40
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        let contentView = UIStackView(arrangedSubviews: [colorPicker, alphaLabel, slider])
        contentView.spacing = 4.0
        contentView.axis = .vertical

        addSubviewWithAutoLayout(contentView)
        layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            colorPicker.widthAnchor.constraint(equalTo: colorPicker.heightAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])

        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = UIColor(white: 1.0, alpha: 0.1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        currentColor = color
    }

    @objc private func sliderValueChanged(_ slider: UISlider) {
        let newAlpha = CGFloat(slider.value)
        // avoid spamming blur, only re-blur image if the alpha has 0.05+ changes
        guard abs(newAlpha - currentAlpha) >= 0.05 else { return }
        currentAlpha = newAlpha
    }
}
