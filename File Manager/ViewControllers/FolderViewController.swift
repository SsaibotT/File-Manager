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

    var folderInfo: FolderAndFileDetailInfo!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = folderInfo.name
        sizeLabel.text = folderInfo.size
        amountOfFilesLabel.text = folderInfo.amountOfFiles
        creationDateLabel.text  = folderInfo.creationDate
        modofiedDateLabel.text  = folderInfo.modifiedDate
    }
    
    func configFolderViewControl(folderInfo: FolderAndFileDetailInfo) {
        
        self.folderInfo = folderInfo
    }
}
