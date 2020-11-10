//  Copyright © 2019 Andy Liang. All rights reserved.

import UIKit
import SwiftUI

class RootViewController : UIViewController {

    // MARK: view
    private let imageView = UIImageView(image: UIImage())
    private let browseButton = UIButton()
    private let saveButton = UIButton()
    private let blurRadiusLabel = UILabel()
    private let paletteView = CustomPaletteView()
#if !targetEnvironment(macCatalyst)
    private let infoButton = UIButton(type: .detailDisclosure)
#endif
    private var fileName: String?

    private var color: UIColor = UIColor.red.withAlphaComponent(0.5)
    private var alpha: CGFloat = 0.35

    private lazy var blurry = Blurry(size: view.bounds.size) { [weak self] image in
        self?.imageView.image = image
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch blurry.blurStyle {
        case .light:
            return .darkContent
        default:
            return .lightContent
        }
    }

    override func loadView() {
        super.loadView()
        imageView.contentMode = .scaleAspectFill
        view.addInteraction(UIDropInteraction(delegate: self))
        
        paletteView.delegate = self
        paletteView.isHidden = true

        let blurModePicker = UISegmentedControl(items: BlurStyle.allTitles)
        blurModePicker.selectedSegmentIndex = 0
        blurModePicker.addTarget(self, action: #selector(blurModeDidChange), for: .valueChanged)
        if traitCollection.userInterfaceIdiom != .mac {
            blurModePicker.selectedSegmentTintColor = UIColor(white: 1.0, alpha: 0.25)
            blurModePicker.setTitleTextAttributes(blurry.blurStyle.titleAttributes, for: .normal)
        }
        
        blurRadiusLabel.font = .preferredFont(forTextStyle: .headline)
        blurRadiusLabel.text = "Blur Radius (\(Int(CGFloat.defaultBlurRadius)))"

        let radiusSlider = UISlider(frame: .zero, primaryAction: UIAction { [unowned self] action in
            guard let value = (action.sender as? UISlider)?.value else { return }
            let newValue = CGFloat(value.rounded())
            // only re-blur image if there's a diff
            guard abs(newValue - blurry.blurRadius) >= 1 else { return }
            self.blurRadiusLabel.text = "Blur Radius (\(Int(newValue)))"
            self.blurry.blurRadius = newValue
        })
        radiusSlider.isContinuous = true
        radiusSlider.minimumValue = 0.0
        radiusSlider.maximumValue = 200
        radiusSlider.value = Float(CGFloat.defaultBlurRadius)

        browseButton.setTitle("Select Photo", for: .normal)
        browseButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        browseButton.showsMenuAsPrimaryAction = true
        browseButton.menu = UIMenu(title: "Select a Source", children: [
            UIAction(title: "Photo Library", image: UIImage(systemName: "photo")) { [weak self] _ in
                let picker = UIImagePickerController()
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            },
            UIAction(title: "File Browser", image: UIImage(systemName: "folder")) { [weak self] _ in
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image], asCopy: true)
                picker.delegate = self
                self?.present(picker, animated: true, completion: nil)
            }
        ])

        saveButton.isEnabled = false
        saveButton.setTitle("Save Image", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        let shareAction = UIAction(title: "Share") { _ in
            self.processSaveRequest { image in
                let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: [])
                shareSheet.modalPresentationStyle = .popover
                if let popover = shareSheet.popoverPresentationController {
                    popover.sourceView = self.saveButton
                    popover.sourceRect = self.saveButton.bounds
                }
                self.present(shareSheet, animated: true, completion: nil)
            }
        }
        #if targetEnvironment(macCatalyst)
        let saveAction = UIAction(title: "Save to Files") { _ in
            self.processSaveRequest { image in
                let fileName = "blurry-\(self.fileName ?? "image.jpeg")"
                guard let data = image.jpegData(compressionQuality: 0.8),
                      let exportURL = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask)
                        .first?.appendingPathComponent(fileName) else { return }
                do {
                    try data.write(to: exportURL)
                    let browser = UIDocumentPickerViewController(forExporting: [exportURL], asCopy: true)
                    self.present(browser, animated: true, completion: nil)
                } catch {
                    print(error)
                }
            }
        }
        saveButton.menu = UIMenu(title: "Destination", children: [shareAction, saveAction])
        saveButton.showsMenuAsPrimaryAction = true
        #else
        saveButton.addAction(shareAction, for: .touchUpInside)
        #endif

        let contentView = UIStackView(arrangedSubviews: [
            blurModePicker, blurRadiusLabel, radiusSlider, browseButton, saveButton
        ])
        contentView.axis = .vertical
        contentView.distribution = .equalCentering
        contentView.spacing = 12
        contentView.setCustomSpacing(4, after: blurRadiusLabel)

        browseButton.isPointerInteractionEnabled = true
        saveButton.isPointerInteractionEnabled = true
        #if !targetEnvironment(macCatalyst)
        infoButton.isPointerInteractionEnabled = true
        #endif

        view.addSubviewWithAutoLayout(imageView)
        view.addSubviewWithAutoLayout(paletteView)
        view.addSubviewWithAutoLayout(contentView)
        #if !targetEnvironment(macCatalyst)
        infoButton.addAction(UIAction { [weak self] _ in
            let viewController = UINavigationController(rootViewController: UIHostingController(rootView: AboutView()))
            self?.present(viewController, animated: true, completion: nil)
        }, for: .primaryActionTriggered)

        view.addSubviewWithAutoLayout(infoButton)
        #endif

        let guide = view.layoutMarginsGuide
        let safeAreaGuide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // 1. image view
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // 2. color picker view
            paletteView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaGuide.topAnchor, constant: 8),
            paletteView.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor),
            paletteView.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor),
            paletteView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            paletteView.bottomAnchor.constraint(equalTo: view.centerYAnchor).atPriority(.defaultLow),
            // 3. content view
            contentView.topAnchor.constraint(equalTo: paletteView.bottomAnchor, constant: 32),
            contentView.leadingAnchor.constraint(equalTo: paletteView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: paletteView.trailingAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaGuide.bottomAnchor, constant: -8),
        ])

#if !targetEnvironment(macCatalyst)
        NSLayoutConstraint.activate([
            infoButton.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor, constant: -16),
            infoButton.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: -16)
        ])
#endif
        updateUI()
    }

    @objc private func blurModeDidChange(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // dark
            blurry.blurStyle = .dark
        case 1: // light
            blurry.blurStyle = .light
        case 2: // custom
            blurry.blurStyle = .custom(tint: paletteView.currentColor, saturation: paletteView.currentSaturationValue)
        default:
            break
        }
        if segmentedControl.traitCollection.userInterfaceIdiom != .mac {
            segmentedControl.setTitleTextAttributes(blurry.blurStyle.titleAttributes, for: .normal)
        }
        paletteView.isHidden = !blurry.blurStyle.shouldDisplayPicker
        updateUI()
    }

    private func updateUI() {
        let tintColor = blurry.blurStyle.tintColor
        let backgroundColor = blurry.blurStyle.backgroundColor
        view.backgroundColor = backgroundColor
        view.tintColor = tintColor
        blurRadiusLabel.textColor = tintColor
        browseButton.setTitleColor(tintColor, for: .normal)
        browseButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        saveButton.setTitleColor(tintColor, for: .normal)
        saveButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        saveButton.setTitleColor(tintColor.withAlphaComponent(0.35), for: .disabled)
        setNeedsStatusBarAppearanceUpdate()
    }

    private func startProcessing(_ image: UIImage, url: URL?) {
        fileName = url?.lastPathComponent
        saveButton.isEnabled = true
        blurry.currentImage = image
        print("[Blurry] opened file: \(fileName ?? "-")")
    }

    private func processSaveRequest(with saveAction: (UIImage) -> Void) {
        guard let image = blurry.applyBlur() else {
            let failedAlert = UIAlertController(
                title: "Save Failed...",
                message: "There was no source photo.",
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            failedAlert.addAction(cancelAction)
            self.present(failedAlert, animated: true, completion: nil)
            return
        }
        saveAction(image)
    }
}

extension RootViewController : UIDropInteractionDelegate {
    func dropInteraction(
        _ interaction: UIDropInteraction,
        sessionDidUpdate session: UIDropSession
    ) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(
        _ interaction: UIDropInteraction,
        canHandle session: UIDropSession
    ) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { images in
            guard let image = images.first as? UIImage else { return }
            self.startProcessing(image, url: nil)
        }
    }
}

extension RootViewController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first,
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data)
        else {
            let alertController = UIAlertController(
                title: "Invalid Image",
                message: "Blurry failed to open the image, try again.",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        self.startProcessing(image, url: url)
    }
}

extension RootViewController :
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    typealias MediaInfo = [UIImagePickerController.InfoKey : Any]
    func imagePickerController(
        _ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: MediaInfo)
    {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        startProcessing(image, url: nil)
    }
}

extension RootViewController : CustomPaletteViewDelegate {
    func paletteViewDidSelectColor(_ color: UIColor, saturation: CGFloat, in view: CustomPaletteView) {
        blurry.blurStyle = .custom(tint: color, saturation: saturation)
        updateUI()
    }
}
