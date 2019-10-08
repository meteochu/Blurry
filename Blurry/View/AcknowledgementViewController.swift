//
//  AcknowledgementViewController.swift
//  Blurry
//
//  Created by Andy Liang on 2019-10-07.
//  Copyright © 2019 Andy Liang. All rights reserved.
//

import UIKit

class AcknowledgementViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Acknowledgements"
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .footnote)
        textView.isEditable = false
        textView.isSelectable = false
        textView.contentInsetAdjustmentBehavior = .never
        
        view.addSubviewWithAutoLayout(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            textView.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = UIColor(named: "Background")
            textView.backgroundColor = UIColor(named: "Background")
            textView.textColor = .white
        }

        // load the content
        if let filePath = Bundle.main.path(forResource: "Acknowledgement", ofType: "txt"),
            let content = try? String(contentsOfFile: filePath) {
            textView.text = content
        }
    }
}
