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
        
        let identifier = DirectoryController.identifier
        if let folderVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? DirectoryController {
            folderVC.path = path
            viewController.navigationController?.pushViewController(folderVC, animated: true)
        }
    }
    
    static func showDetailFileViewController(from viewController: UIViewController,
                                             fileInfo: FolderAndFileDetailInfo) {
        
        let identifier = FileViewController.identifier
        if let fileVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? FileViewController {
            fileVC.hidesBottomBarWhenPushed = true
            fileVC.configFileViewControl(fileInfo: fileInfo)
            viewController.navigationController?.show(fileVC, sender: viewController)
        }
    }
    
    static func showDetailFolderViewController(from viewController: UIViewController,
                                               folderInfo: FolderAndFileDetailInfo) {
        
        let identifier = FolderViewController.identifier
        if let folderVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? FolderViewController {
            folderVC.hidesBottomBarWhenPushed = true
            
            folderVC.configFolderViewControl(folderInfo: folderInfo)
            viewController.navigationController?.show(folderVC, sender: viewController)
        }
    }
    
    static func showImageViewController(from viewController: UIViewController,
                                        image: UIImage) {
        
        let identifier = ImageViewController.identifier
        if let imageVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? ImageViewController {
            imageVC.hidesBottomBarWhenPushed = true
            imageVC.configImageViewController(image: image)
            viewController.navigationController?.show(imageVC, sender: viewController)
        }
    }
    
    static func showPDFViewController(from viewController: UIViewController,
                                      document: PDFDocument) {
        
        let identifier = PDFViewController.identifier
        if let pdfVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? PDFViewController {
            pdfVC.hidesBottomBarWhenPushed = true
            pdfVC.configPDFViewController(document: document)
            viewController.navigationController?.show(pdfVC, sender: viewController)
        }
    }
    
    static func showTextViewController(from viewController: UIViewController,
                                       text: NSAttributedString) {
        
        let identifier = TextViewController.identifier
        if let textVC = viewController.storyboard?
            .instantiateViewController(withIdentifier: identifier) as? TextViewController {
            textVC.hidesBottomBarWhenPushed = true
            textVC.configTXTViewController(text: text)
            viewController.navigationController?.show(textVC, sender: viewController)
        }
    }
}
