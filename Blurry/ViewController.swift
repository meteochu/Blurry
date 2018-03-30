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
            self.imageView.image = image
        }
    }
    
    /// the colour to tint the image, used with BlurStyle.tintColor(color)
    private var currentColor: UIColor = UIColor.red.withAlphaComponent(0.35)
    
    /// the color alpha to tint the image, used with BlurStyle.tintColor(color)
    private var colorAlpha: CGFloat = 0.35
    
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
        let tintColor = blurry.blurStyle.tintColor
        let backgroundColor = blurry.blurStyle.backgroundColor
        self.view.backgroundColor = backgroundColor
        self.view.tintColor = tintColor
        blurRadiusLabel.textColor = tintColor
        opacityLabel.textColor = tintColor
        saveButton.layer.borderColor = tintColor.cgColor
    }
    
    // MARK: - IBAction methods
    
    @IBAction func blurModeButtonChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            blurry.blurStyle = .dark
            self.colorPickerBackgroundView.isHidden = true
        case 1:
            blurry.blurStyle = .light
            self.colorPickerBackgroundView.isHidden = true
        case 2:
            blurry.blurStyle = .tintColor(currentColor)
            self.colorPickerBackgroundView.isHidden = false
        default:
            break
        }
        self.updateViewColors()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = CGFloat(Int(sender.value))
        // only re-blur image if there's a diff
        if abs(value - blurry.blurRadius) >= 1 {
            blurRadiusLabel.text = "Blur Radius (\(Int(value)))".uppercased()
            blurry.blurRadius = value
        }
    }
    
    @IBAction func alphaSliderValueChanged(_ sender: UISlider) {
        let newAlpha = CGFloat(sender.value)
        if case .tintColor(let color) = blurry.blurStyle, abs(newAlpha - colorAlpha) >= 0.05 {
            // avoid spamming blur, only re-blur image if the alpha has 0.05+ changes
            blurry.blurStyle = .tintColor(color.withAlphaComponent(newAlpha))
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
        let alertController = UIAlertController(title: "Processing Image...", message: nil, preferredStyle: .actionSheet)
        self.present(alertController, animated: true) {
            if let image = self.blurry.applyBlur() {
                alertController.dismiss(animated: true) {
                    let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: [])
                    shareSheet.modalPresentationStyle = .popover
                    shareSheet.popoverPresentationController?.sourceView = sender
                    shareSheet.popoverPresentationController?.sourceRect = sender.bounds
                    self.present(shareSheet, animated: true, completion: nil)
                }
            } else {
                alertController.dismiss(animated: true) {
                    let failedAlert = UIAlertController(title: "Save Failed...", message: "There was no source photo...", preferredStyle: .alert)
                    failedAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    self.present(failedAlert, animated: true, completion: nil)
                }
            }
        }
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
        self.saveButton.isEnabled = true
        blurry.currentImage = image
    }
    
}

// MARK: - ViewController + ChromaColorPickerDelegate
extension ViewController: ChromaColorPickerDelegate {
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        self.currentColor = color.withAlphaComponent(colorAlpha)
        blurry.blurStyle = .tintColor(currentColor)
        self.updateViewColors()
    }
    
}
