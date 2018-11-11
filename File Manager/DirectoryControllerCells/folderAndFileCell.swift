//
//  FolderAndFileCell.swift
//  File Manager
//
//  Created by Serhii on 10/30/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class FolderAndFileCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    
    var pasingInfoForButton: (() -> Void)?
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        pasingInfoForButton!()
    }

    func cellConfig(name: String, image: UIImage) {
        nameLabel.text = name
        cellImage.image = image
    }

}
