//
//  AcknowledgementViewController.swift
//  Blurry
//
//  Created by Andy Liang on 8/2/17.
//  Copyright © 2017 Andy Liang. All rights reserved.
//

import UIKit

class AcknowledgementViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let filePath = Bundle.main.path(forResource: "Acknowledgement", ofType: "txt")!
        if let acknowledgements = try? String(contentsOfFile: filePath) {
            self.textView.text = acknowledgements
        }
    }

}
