//
//  TextViewController.swift
//  File Manager
//
//  Created by Serhii on 11/7/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var txtView: UITextView!
    var text: NSAttributedString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtView.attributedText = text
    }
    
    func configTXTViewController(text: NSAttributedString) {
        self.text = text
    }
    
}
