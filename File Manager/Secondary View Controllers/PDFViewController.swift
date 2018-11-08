//
//  PDFViewController.swift
//  File Manager
//
//  Created by Serhii on 11/7/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView!
    var document: PDFDocument?

    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView.document = document
    }
    
    func configPDFViewController(document: PDFDocument) {
        self.document = document
    }
}
