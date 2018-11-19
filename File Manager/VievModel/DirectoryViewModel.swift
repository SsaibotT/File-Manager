//
//  DirectoryViewModel.swift
//  File Manager
//
//  Created by Serhii on 11/11/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import Foundation
import RxSwift
import PDFKit

class DirectoryViewModel {
    
    var contents = [Content]()
    var filteredContents: Variable<[Content]> = Variable([Content]())
    var searchText: String = ""
    var disposeBag = DisposeBag()
    var helper = Helper()
    var path: URL! {
        didSet {
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: path,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: FileManager
                                                                        .DirectoryEnumerationOptions
                                                                        .skipsHiddenFiles)
                for url in urls {
                    contents.append(Content(url: url))
                }
                
                filteredContents.value = contents
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
//    init() {
//        if path == nil {
//            path = URL.init(string: "file:///Users/ghjkghkj/Desktop/folder/")
//        }
//
//        sortTheContents(array: filteredContents.value)
//    }
    
    func loaded() {
        if path == nil {
            path = URL.init(string: "file:///Users/ghjkghkj/Desktop/folder/")
        }
        
        sortTheContents(array: filteredContents.value)
    }
    
    func delete(index: Int) {
        let name = filteredContents.value[index]
        if (try? FileManager.default.removeItem(atPath: name.url!.path)) != nil {
            contents.remove(at: (contents.map({$0.url!.lastPathComponent})
                .index(of: name.url!.lastPathComponent))!)
            filteredContents.value.remove(at: index)
            sortTheContents(array: filteredContents.value)
        }
    }
    
    func add(name: String) {
        let path = self.path.appendingPathComponent(name)
        
        if (try? FileManager.default.createDirectory(atPath: path.path,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)) != nil {
            
            contents.append(Content(url: path))
            
            if searchText == "" || searchText == name {
                filteredContents.value.append(Content(url: path))
            }
            sortTheContents(array: filteredContents.value)
        }
    }
    
    func addImage(nameUrl: URL) {
        
        let path = self.path.appendingPathComponent(nameUrl.lastPathComponent)
        
        do {
            try FileManager.default.copyItem(at: nameUrl, to: path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        filteredContents.value.append(Content(url: path))
        contents.append(Content(url: path))
        sortTheContents(array: filteredContents.value)
    }
    
    func sortTheContents(array: [Content]) {
        
        var arrayOfDirectories = [Content]()
        var arrayOfFiles = [Content]()
        
        for content in array {
            content.getType() == Type.directory ?
                arrayOfDirectories.append(content) :
                arrayOfFiles.append(content)
        }
        
        let sortedDictionaryArray = arrayOfDirectories.sorted {$0.url!.lastPathComponent < $1.url!.lastPathComponent}
        let sortedFilesArray = arrayOfFiles.sorted {$0.url!.lastPathComponent < $1.url!.lastPathComponent}
        filteredContents.value = sortedDictionaryArray + sortedFilesArray
    }
    
    func generatedTableFromArray(searchText: String) {
        
        filteredContents.value = contents.filter {(title: Content) -> Bool in
            if title.url!.lastPathComponent.lowercased().contains(searchText.lowercased()) {
                return true
            } else if searchText == "" {
                return true
            } else {
                return false
            }
        }
        sortTheContents(array: filteredContents.value)
    }
    
    func goToFolderInfo(cell: UITableViewCell,
                        indexPath: IndexPath,
                        viewController: UIViewController) {
        
        let folderName = filteredContents.value[indexPath.row]
        var attributes: NSDictionary?
        do {
            attributes = try FileManager.default
                .attributesOfItem(atPath: folderName.url!.path) as NSDictionary
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let folderSize = helper.casting(bytes: Double(helper
            .folderSizeAndAmount(folderPath: folderName.url!.path).0))
        let folderAmoundOfFiles = "\(helper.folderSizeAndAmount(folderPath: folderName.url!.path).1)"
        let creationDate = helper.formatingDate(date: (attributes?.fileCreationDate())!)
        let modifiedDate = helper.formatingDate(date: (attributes?.fileModificationDate())!)
        
        ShowControllers.showDetailFolderViewController(from: viewController,
                                                       name: folderName.url!.lastPathComponent,
                                                       size: folderSize,
                                                       amountOfFiles: folderAmoundOfFiles,
                                                       creationDate: creationDate,
                                                       modifiedDate: modifiedDate)
    }
    
    func goToFileInfo(cell: UITableViewCell,
                      indexPath: IndexPath,
                      viewController: UIViewController) {
        
        let fileName = filteredContents.value[indexPath.row]
        var attributes: NSDictionary?
        do {
            attributes = try FileManager.default.attributesOfItem(atPath: fileName.url!.path) as NSDictionary
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let fileSize     = helper.casting(bytes: Double((attributes?.fileSize())!))
        let creationDate = helper.formatingDate(date: (attributes?.fileCreationDate())!)
        let modifiedDate = helper.formatingDate(date: (attributes?.fileModificationDate())!)
        
        ShowControllers.showDetailFileViewController(from: viewController,
                                                     name: fileName.url!.lastPathComponent,
                                                     size: fileSize,
                                                     creationDate: creationDate,
                                                     modifiedDate: modifiedDate)
    }
    
    func goToImageViewController(cell: UITableViewCell,
                                 indexPath: IndexPath,
                                 viewController: UIViewController) {
        var data: Data!
        
        do {
            data = try Data(contentsOf: filteredContents.value[indexPath.row].url!)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        ShowControllers.showImageViewController(from: viewController,
                                                image: UIImage(data: data!)!)
        
    }
    
    func goToPDFViewController(cell: UITableViewCell,
                               indexPath: IndexPath,
                               viewController: UIViewController) {
        let document = PDFDocument(url: filteredContents.value[indexPath.row].url!)
        ShowControllers.showPDFViewController(from: viewController,
                                              document: document!)
    }
    
    func goToDirectoryViewController(cell: UITableViewCell,
                                     indexPath: IndexPath,
                                     viewController: UIViewController) {
        
        let fileName = filteredContents.value[indexPath.row].url!.lastPathComponent
        let path = self.path.appendingPathComponent(fileName)
        ShowControllers.showDirectoryViewController(from: viewController, path: path)
    }
    
    func goToTextViewController(cell: UITableViewCell,
                                indexPath: IndexPath,
                                viewController: UIViewController) {
        
        let textContent = filteredContents.value[indexPath.row].typeOfText()
        ShowControllers.showTextViewController(from: viewController,
                                               text: textContent)
    }
}
