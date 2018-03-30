//
//  Blurry.swift
//  Blurry
//
//  Created by Andy Liang on 3/29/18.
//  Copyright © 2018 Andy Liang. All rights reserved.
//

import UIKit

class Blurry: NSObject {
    
    //
    private let completionBlock: (UIImage) -> Void
    private let queue: DispatchQueue
    private let boundingSize: CGSize
    // dispatch work items
    private var isProcessing: Bool = false
    private var nextWorkItem: DispatchWorkItem?
    
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
        didSet {
            self.scaledRadius = blurRadius / scaleRatio
        }
    }
    
    var blurStyle: BlurStyle = .dark {
        didSet { self.processImage() }
    }
    
    private var scaledImage: UIImage? {
        didSet { self.processImage() }
    }
    
    private var scaleRatio: CGFloat = 1.0 {
        didSet {
            self.scaledRadius = blurRadius / scaleRatio
        }
    }
    
    private var scaledRadius: CGFloat = 60.0 {
        didSet { self.processImage() }
    }
    
    init(boundingSize: CGSize, completionBlock: @escaping (UIImage) -> Void) {
        self.boundingSize = boundingSize
        self.completionBlock = completionBlock
        self.queue = DispatchQueue(label: String(describing: type(of: self)), qos: .utility, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
        super.init()
    }
    
    func processImage(for workItem: DispatchWorkItem? = nil) {
        self.queue.async {
            guard let image = self.scaledImage else {
                return // image is nil, ignore
            }
            
            if self.isProcessing {
                self.nextWorkItem = self.createWorkItem(for: image, blurStyle: self.blurStyle, radius: self.scaledRadius)
            } else {
                let item = workItem ?? self.createWorkItem(for: image, blurStyle: self.blurStyle, radius: self.scaledRadius)
                self.queue.async(execute: item)
            }
        }
    }
    
    private func createWorkItem(for image: UIImage, blurStyle: BlurStyle, radius: CGFloat) -> DispatchWorkItem {
        return DispatchWorkItem {
            self.isProcessing = true
            let start = Date()
            let blurredImage = image.applying(style: blurStyle, with: radius)
            let end = Date()
            print("Time took to process image: \(end.timeIntervalSince(start))")
            self.completionBlock(blurredImage)
            self.isProcessing = false
            if let nextItem = self.nextWorkItem {
                self.nextWorkItem = nil
                self.processImage(for: nextItem)
            }
        }
    }

    // final image that is saved
    func applyBlur() -> UIImage? {
        guard let image = self.currentImage else {
            return nil
        }
        return image.applying(style: blurStyle, with: blurRadius)
    }

}
