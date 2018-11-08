//
//  ImageViewController.swift
//  File Manager
//
//  Created by Serhii on 11/1/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.image = image

    }
    
    func configImageViewController(image: UIImage) {
        self.image = image
    }
}
