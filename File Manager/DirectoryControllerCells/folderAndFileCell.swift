//
//  folderAndFileCell.swift
//  File Manager
//
//  Created by Serhii on 10/30/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class folderAndFileCell: UITableViewCell {
    
    var delegate: CustomCellDelegator!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

    @IBAction func infoButtonAction(_ sender: UIButton) {
        
        if(self.delegate != nil){
            self.delegate.callSegueFromCell(sender: sender)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

protocol CustomCellDelegator {
    func callSegueFromCell(sender: UIButton)
}

