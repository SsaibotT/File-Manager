//
//  FileViewController.swift
//  File Manager
//
//  Created by Serhii on 10/26/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class FileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var modifiedDateLabel: UILabel!

    var name: String?
    var size: String?
    var creationDate: String?
    var modifiedDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
        sizeLabel.text = size
        creationDateLabel.text = creationDate
        modifiedDateLabel.text = modifiedDate
    }
    
    func configFileViewControl(name: String,
                               size: String,
                               creationDate: String,
                               modifiedDate: String) {
        self.name = name
        self.size = size
        self.creationDate = creationDate
        self.modifiedDate = modifiedDate
    }
}
