//
//  ViewController.swift
//  Blurry
//
//  Created by Andy Liang on 6/26/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit

enum BlurStyle {
    case dark
    case light
    case extraLight
    case tintColor(UIColor)
    
    var tintColor: UIColor {
        switch self {
        case .dark:
            return .white
        case .light:
            return UIColor(red: 0.15, green: 0.22, blue: 0.5, alpha: 1)
        case .extraLight:
            return UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        case .tintColor:
            return .white
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .dark:
            return UIColor(red: 0.15, green: 0.22, blue: 0.5, alpha: 1)
        case .light:
            return UIColor(white: 0.9, alpha: 1)
        case .extraLight:
            return .white
        case .tintColor:
            return .darkGray
        }
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    private var blurredImage: UIImage? {
        didSet {
            self.imageView.image = blurredImage
        }
    }
    
    private var originalImage: UIImage? {
        didSet {
            guard let _ = self.originalImage else { return }
            self.saveButton.isEnabled = true
            self.processImage()
        }
    }
    
    private var blurRadius: CGFloat = 60.0 {
        didSet {
            self.processImage()
        }
    }
    
    private var blurStyle: BlurStyle = .dark {
        didSet {
            if case .tintColor = blurStyle {
                self.colorPicker.isHidden = false
            } else {
                self.colorPicker.isHidden = true
            }
            self.processImage()
            self.updateViewColors()
        }
    }
    
    private var currentColor: UIColor = UIColor(white: 1, alpha: 0.5)
    
    @IBOutlet weak var colorPicker: ChromaColorPicker!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        super.loadView()
        self.colorPicker.hexLabel.textColor = .white
        self.colorPicker.stroke = 6
        self.colorPicker.delegate = self
        self.colorPicker.isHidden = true
        self.colorPicker.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        self.colorPicker.layer.cornerRadius = 16
        self.colorPicker.layer.masksToBounds = true
        self.updateViewColors()
    }
    
    func updateViewColors() {
        self.view.tintColor = self.blurStyle.tintColor
        self.view.backgroundColor = self.blurStyle.backgroundColor
    }
    
    func processImage() {
        guard let image = self.originalImage else { return }
        var blurredImage: UIImage?
        switch self.blurStyle {
        case .dark:
            blurredImage = UIImageEffects.imageByApplyingDarkEffect(to: image, withRadius: self.blurRadius)
        case .extraLight:
            blurredImage = UIImageEffects.imageByApplyingExtraLightEffect(to: image, withRadius: self.blurRadius)
        case .light:
            blurredImage = UIImageEffects.imageByApplyingLightEffect(to: image, withRadius: self.blurRadius)
        case .tintColor(let color):
            print(color)
            blurredImage = UIImageEffects.imageByApplyingBlur(to: image, withRadius: self.blurRadius, tintColor: color, saturationDeltaFactor: -1, maskImage: nil)
            break
        }
        self.blurredImage = blurredImage
    }
    
    @IBAction func blurModeButtonChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.blurStyle = .dark
        case 1:
            self.blurStyle = .light
        case 2:
            self.blurStyle = .extraLight
        case 3:
            self.blurStyle = .tintColor(currentColor)
        default: return
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let value = CGFloat(sender.value)
        if abs(value - blurRadius) >= 5 {
            self.blurRadius = value
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

extension ViewController: ChromaColorPickerDelegate {
    
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        self.currentColor = color.withAlphaComponent(0.35)
        self.blurStyle = .tintColor(currentColor)
    }
    
}
