//
//  ShowControllers.swift
//  File Manager
//
//  Created by Serhii on 11/18/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import Foundation
import UIKit
import PDFKit

class ShowControllers {
    
    static func showDirectoryViewController(from viewController: UIViewController,
                                            path: URL) {
        
        let identifier = "DirectoryController"
        if let folderVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? DirectoryController {
            folderVC.directoryViewModel.path = path
            viewController.navigationController?.pushViewController(folderVC, animated: true)
        }
    }
    
    static func showDetailFileViewController(from viewController: UIViewController,
                                             name: String,
                                             size: String,
                                             creationDate: String,
                                             modifiedDate: String) {
        
        let identifier = "FileViewController"
        if let fileVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? FileViewController {
            fileVC.hidesBottomBarWhenPushed = true
            fileVC.configFileViewControl(name: name,
                                         size: size,
                                         creationDate: creationDate,
                                         modifiedDate: modifiedDate)
            viewController.navigationController?.show(fileVC, sender: viewController)
        }
    }
    
    static func showDetailFolderViewController(from viewController: UIViewController,
                                               name: String,
                                               size: String,
                                               amountOfFiles: String,
                                               creationDate: String,
                                               modifiedDate: String) {
        
        let identifier = "FolderViewController"
        if let folderVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? FolderViewController {
            folderVC.hidesBottomBarWhenPushed = true
            folderVC.configFolderViewControl(name: name,
                                             size: size,
                                             amountOfFiles: amountOfFiles,
                                             creationDate: creationDate,
                                             modifiedDate: modifiedDate)
            viewController.navigationController?.show(folderVC, sender: viewController)
        }
    }
    
    static func showImageViewController(from viewController: UIViewController,
                                        image: UIImage) {
        
        let identifier = "ImageViewController"
        if let imageVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? ImageViewController {
            imageVC.hidesBottomBarWhenPushed = true
            imageVC.configImageViewController(image: image)
            viewController.navigationController?.show(imageVC, sender: viewController)
        }
    }
    
    static func showPDFViewController(from viewController: UIViewController,
                                      document: PDFDocument) {
        
        let identifier = "PDFViewController"
        if let pdfVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? PDFViewController {
            pdfVC.hidesBottomBarWhenPushed = true
            pdfVC.configPDFViewController(document: document)
            viewController.navigationController?.show(pdfVC, sender: viewController)
        }
    }
    
    static func showTextViewController(from viewController: UIViewController,
                                       text: NSAttributedString) {
        
        let identifier = "TextViewController"
        if let textVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? TextViewController {
            textVC.hidesBottomBarWhenPushed = true
            textVC.configTXTViewController(text: text)
            viewController.navigationController?.show(textVC, sender: viewController)
        }
    }
}
