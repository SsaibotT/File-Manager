//
//  FolderViewController.swift
//  File Manager
//
//  Created by Serhii on 10/27/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var amountOfFilesLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var modofiedDateLabel: UILabel!

    var name: String?
    var size: String?
    var amountOfFiles: String?
    var creationDate: String?
    var modifiedDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
        sizeLabel.text = size
        amountOfFilesLabel.text = amountOfFiles
        creationDateLabel.text  = creationDate
        modofiedDateLabel.text  = modifiedDate
    }
}
