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

    var fileInfo: FolderAndFileDetailInfo!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = fileInfo.name
        sizeLabel.text = fileInfo.size
        creationDateLabel.text = fileInfo.creationDate
        modifiedDateLabel.text = fileInfo.modifiedDate
    }
    
    func configFileViewControl(fileInfo: FolderAndFileDetailInfo) {
        self.fileInfo = fileInfo
    }
}
