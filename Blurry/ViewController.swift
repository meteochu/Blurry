//
//  ViewController.swift
//  Blurry
//
//  Created by Andy Liang on 6/26/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - view / storyboard properties
  
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var blurRadiusLabel: UILabel!
    
    @IBOutlet weak var opacityLabel: UILabel!
    
    @IBOutlet weak var colorPicker: ChromaColorPicker!
    
    @IBOutlet weak var colorPickerBackgroundView: UIView!
    
    private lazy var blurry = Blurry(boundingSize: self.view.bounds.size) { image in
        DispatchQueue.main.async {
            self.blurredImage = image
        }
    }
    
    // MARK: - image + blur properties
    
    /// the image loaded from Photos
    private var originalImage: UIImage? {
        didSet {
            guard let image = self.originalImage else { return }
            self.saveButton.isEnabled = true
            blurry.currentImage = image
        }
    }
    
    /// the blurred image that can be saved
    private var blurredImage: UIImage? {
        didSet {
            self.imageView.image = blurredImage
        }
    }
    
    /// the blur style, default .dark
    private var blurStyle: BlurStyle = .dark {
        didSet {
            if case .tintColor = blurStyle {
                self.colorPickerBackgroundView.isHidden = false
            } else {
                self.colorPickerBackgroundView.isHidden = true
            }
            self.updateViewColors()
            blurry.blurStyle = blurStyle
        }
    }
    
    /// the radius to blur the image by
    private var blurRadius: CGFloat = 60.0 {
        didSet {
            blurRadiusLabel.text = "Blur Radius (\(Int(blurRadius)))".uppercased()
            blurry.blurRadius = blurRadius
        }
    }
    
    /// the colour to tint the image, used with BlurStyle.tintColor(color)
    fileprivate var currentColor: UIColor = UIColor.red.withAlphaComponent(0.35)
    
    /// the color alpha to tint the image, used with BlurStyle.tintColor(color)
    fileprivate var colorAlpha: CGFloat = 0.35
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - view methods
    
    override func loadView() {
        super.loadView()
        self.colorPickerBackgroundView.isHidden = true
        self.colorPickerBackgroundView.layer.cornerRadius = 16
        self.colorPickerBackgroundView.layer.masksToBounds = true
        self.colorPickerBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        self.colorPicker.hexLabel.textColor = .white
        self.colorPicker.stroke = 6
        self.colorPicker.delegate = self
        self.updateViewColors()
    }
    
    func updateViewColors() {
        self.view.tintColor = self.blurStyle.tintColor
        self.view.backgroundColor = self.blurStyle.backgroundColor
        blurRadiusLabel.textColor = self.blurStyle.tintColor
        opacityLabel.textColor = self.blurStyle.tintColor
    }
    
    // MARK: - blur methods + its helpers
    
    
    // MARK: - IBAction methods
    
    @IBAction func blurModeButtonChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.blurStyle = .dark
        case 1:
            self.blurStyle = .light
        case 2:
            self.blurStyle = .tintColor(currentColor)
        default:
            return
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = CGFloat(Int(sender.value))
        // only re-blur image if there's a diff
        if abs(value - blurRadius) >= 1 {
            self.blurRadius = value
        }
    }
    
    @IBAction func alphaSliderValueChanged(_ sender: UISlider) {
        let newAlpha = CGFloat(sender.value)
        if case .tintColor(let color) = self.blurStyle, abs(newAlpha - colorAlpha) >= 0.05 {
            // avoid spamming blur, only re-blur image if the alpha has 0.05+ changes
            self.blurStyle = .tintColor(color.withAlphaComponent(newAlpha))
            self.colorAlpha = newAlpha
        }
    }
    
    @IBAction func didTapPhotosButton(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = sender
        imagePicker.popoverPresentationController?.sourceRect = sender.bounds
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        guard let image = self.blurredImage else { return }
        let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: [])
        shareSheet.modalPresentationStyle = .popover
        shareSheet.popoverPresentationController?.sourceView = sender
        shareSheet.popoverPresentationController?.sourceRect = sender.bounds
        self.present(shareSheet, animated: true, completion: nil)
    }
}

// MARK: - ViewController + UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        self.originalImage = image
    }
    
}

// MARK: - ViewController + ChromaColorPickerDelegate
extension ViewController: ChromaColorPickerDelegate {
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        self.currentColor = color.withAlphaComponent(colorAlpha)
        self.blurStyle = .tintColor(currentColor)
    }
    
}
