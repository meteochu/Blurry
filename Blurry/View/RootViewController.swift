//  Copyright © 2019 Andy Liang. All rights reserved.

import UIKit

class RootViewController : UIViewController {

    // MARK: view
    private let imageView = UIImageView(image: UIImage())
    private let browseButton = UIButton()
    private let saveButton = UIButton()
    private let blurRadiusLabel = UILabel()
    private let colorPickerView = ColorPickerView()
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
        
        colorPickerView.delegate = self
        colorPickerView.isHidden = true

        let blurModePicker = UISegmentedControl(items: BlurStyle.allTitles)
        blurModePicker.selectedSegmentIndex = 0
        blurModePicker.addTarget(self, action: #selector(blurModeDidChange), for: .valueChanged)
        blurModePicker.setTitleTextAttributes(blurry.blurStyle.titleAttributes, for: .normal)
        blurModePicker.selectedSegmentTintColor = UIColor(white: 1.0, alpha: 0.25)
        
        blurRadiusLabel.font = .preferredFont(forTextStyle: .headline)
        blurRadiusLabel.text = "Blur Radius (\(Int(CGFloat.defaultBlurRadius)))"

        let radiusSlider = UISlider()
        radiusSlider.isContinuous = true
        radiusSlider.minimumValue = 0.0
        radiusSlider.maximumValue = 200
        radiusSlider.value = Float(CGFloat.defaultBlurRadius)
        radiusSlider.addTarget(self, action: #selector(radiusSliderValueChanged), for: .valueChanged)

        browseButton.setTitle("Select Photo", for: .normal)
        browseButton.addTarget(self, action: #selector(didTapBrowseButton), for: .touchUpInside)
        browseButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)

        saveButton.isEnabled = false
        saveButton.setTitle("Save Image", for: .normal)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        saveButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)

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
        view.addSubviewWithAutoLayout(colorPickerView)
        view.addSubviewWithAutoLayout(contentView)
        #if !targetEnvironment(macCatalyst)
        infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
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
            colorPickerView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaGuide.topAnchor, constant: 8),
            colorPickerView.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor),
            colorPickerView.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor),
            colorPickerView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            colorPickerView.bottomAnchor.constraint(equalTo: view.centerYAnchor).atPriority(.defaultLow),
            // 3. content view
            contentView.topAnchor.constraint(equalTo: colorPickerView.bottomAnchor, constant: 32),
            contentView.leadingAnchor.constraint(equalTo: colorPickerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: colorPickerView.trailingAnchor),
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
            blurry.blurStyle = .tintColor(colorPickerView.color)
        default:
            break
        }
        segmentedControl.setTitleTextAttributes(blurry.blurStyle.titleAttributes, for: .normal)
        colorPickerView.isHidden = !blurry.blurStyle.shouldDisplayPicker
        updateUI()
    }

    @objc private func didTapSaveButton(_ button: UIButton) {
        let alertController = UIAlertController(title: "Processing...", message: nil, preferredStyle: .actionSheet)
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = button
            popover.sourceRect = button.bounds
        }
        present(alertController, animated: true) {
            self.processSaveRequest(from: button, with: alertController)
        }
    }

    @objc private func didTapBrowseButton(_ button: UIButton) {
        var prompt = Prompt(title: "Select a Source", source: button)
        prompt.add(title: "Photo Library") {
            let picker = UIImagePickerController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        prompt.add(title: "File Browser") {
            let picker = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .import)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        present(prompt.alertController, animated: true, completion: nil)
    }

    @objc private func radiusSliderValueChanged(_ slider: UISlider) {
        let newValue = CGFloat(Int(slider.value))
        // only re-blur image if there's a diff
        guard abs(newValue - blurry.blurRadius) >= 1 else { return }
        blurRadiusLabel.text = "Blur Radius (\(Int(newValue)))"
        blurry.blurRadius = newValue
    }

    @objc private func didTapInfoButton() {
        let viewController = UINavigationController(rootViewController: AboutViewController())
        present(viewController, animated: true, completion: nil)
    }

    private func updateUI() {
        let tintColor = blurry.blurStyle.tintColor
        let backgroundColor = blurry.blurStyle.backgroundColor
        view.backgroundColor = backgroundColor
        view.tintColor = tintColor
        blurRadiusLabel.textColor = tintColor
        colorPickerView.alphaLabel.textColor = tintColor
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

    private func processSaveRequest(from button: UIButton, with alertController: UIAlertController) {
        if let image = blurry.applyBlur() {
            func showShareSheet() {
                let shareSheet = UIActivityViewController(activityItems: [image], applicationActivities: [])
                shareSheet.modalPresentationStyle = .popover
                if let popover = shareSheet.popoverPresentationController {
                    popover.sourceView = button
                    popover.sourceRect = button.bounds
                }
                self.present(shareSheet, animated: true, completion: nil)
            }

            func showSavePrompt() {
                let fileName = "blurry-\(self.fileName ?? "image.jpeg")"
                guard let data = image.jpegData(compressionQuality: 0.8),
                    let exportURL = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask)
                        .first?.appendingPathComponent(fileName) else { return }
                do {
                    try data.write(to: exportURL)
                    let browser = UIDocumentPickerViewController(url: exportURL, in: .exportToService)
                    self.present(browser, animated: true, completion: nil)
                } catch {
                    print(error)
                }
            }

            alertController.dismiss(animated: true) {
#if targetEnvironment(macCatalyst)
                var prompt = Prompt(source: button)
                prompt.add(title: "Share", action: showShareSheet)
                prompt.add(title: "Save to Files", action: showSavePrompt)
                self.present(prompt.alertController, animated: true, completion: nil)
#else
                showShareSheet()
#endif
            }
        } else {
            alertController.dismiss(animated: true) {
                let failedAlert = UIAlertController(
                    title: "Save Failed...",
                    message: "There was no source photo.",
                    preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                failedAlert.addAction(cancelAction)
                self.present(failedAlert, animated: true, completion: nil)
            }
        }
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
        // 1. make sure we can import first...
        guard controller.documentPickerMode == .import else { return }
        // 2. load the image by loading the data from URL first
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

extension RootViewController : ColorPickerDelegate {
    func colorPickerDidChooseColor(_ picker: ColorPickerView, color: UIColor) {
        blurry.blurStyle = .tintColor(color)
        updateUI()
    }
}
