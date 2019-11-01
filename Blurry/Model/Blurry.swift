//
//  Blurry.swift
//  Blurry
//
//  Created by Andy Liang on 3/29/18.
//  Copyright © 2018 Andy Liang. All rights reserved.
//

import UIKit

class Blurry {
    private let completionHandler: (UIImage) -> Void
    private let completionQueue: DispatchQueue
    private let boundingSize: CGSize
    private let processQueue = DispatchQueue(
        label: "Blurry", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .workItem)

    var currentImage: UIImage? {
        didSet {
            guard let image = currentImage else { return }
            if image.size.height < boundingSize.height || image.size.width < boundingSize.width {
                scaledImage = image
            } else {
                let (size, ratio) = image.size.aspectFill(ratio: boundingSize)
                scaledImage = image.scaled(to: size)
                self.scaleRatio = ratio
            }
        }
    }

    var blurRadius: CGFloat = 60.0 {
        didSet { scaledRadius = blurRadius / scaleRatio }
    }

    var blurStyle: BlurStyle = .dark {
        didSet { processImage() }
    }

    private var scaledImage: UIImage? {
        didSet { processImage() }
    }

    private var scaleRatio: CGFloat = 1.0 {
        didSet { scaledRadius = blurRadius / scaleRatio }
    }

    private var scaledRadius: CGFloat = 60.0 {
        didSet { processImage() }
    }

    private var isProcessing = false
    private var nextWorkItem: DispatchWorkItem?

    init(size: CGSize, queue: DispatchQueue = .main, completion: @escaping (UIImage) -> Void) {
        boundingSize = size
        completionQueue = queue
        completionHandler = completion
    }


    private func processImage(for workItem: DispatchWorkItem? = nil) {
        processQueue.async { [weak self] in
            // if the queue image is nil, ignore
            guard let _self = self, let image = _self.scaledImage else { return }
            if _self.isProcessing {
                _self.nextWorkItem = _self.createWorkItem(for: image)
            } else {
                let item = workItem ?? _self.createWorkItem(for: image)
                _self.processQueue.async(execute: item)
            }
        }
    }

    private func createWorkItem(for image: UIImage) -> DispatchWorkItem {
        let style = blurStyle
        let radius = blurRadius
        return DispatchWorkItem {
            self.isProcessing = true
            let startTime = Date()
            let blurredImage = image.applying(style: style, with: radius)
            let length = -startTime.timeIntervalSinceNow.rounded(toPlaces: 4)
            print("[Blurry] Time took to apply blur: \(length)s")
            self.completionQueue.async {
                self.completionHandler(blurredImage)
            }
            // Start processing next item if available...
            self.isProcessing = false
            if let nextItem = self.nextWorkItem {
                self.nextWorkItem = nil
                self.processImage(for: nextItem)
            }
        }
    }

    // final image that is saved
    func applyBlur() -> UIImage? {
        guard let image = currentImage else { return nil }
        let blurred = image.applying(style: blurStyle, with: blurRadius)
        return UIImage(cgImage: blurred.cgImage!, scale: image.scale, orientation: image.imageOrientation)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
