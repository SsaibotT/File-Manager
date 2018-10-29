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

        self.nameLabel.text = self.name
        self.sizeLabel.text = self.size
        self.amountOfFilesLabel.text = self.amountOfFiles
        self.creationDateLabel.text  = self.creationDate
        self.modofiedDateLabel.text  = self.modifiedDate
    }
    


}
