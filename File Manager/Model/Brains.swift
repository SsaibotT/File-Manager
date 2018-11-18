//
//  Brains.swift
//  File Manager
//
//  Created by Serhii on 10/30/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class Brains: NSObject {

    var contents = [Content]()
    var filteredContents = [Content]()
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
                
                filteredContents = contents
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
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
        filteredContents = sortedDictionaryArray + sortedFilesArray
    }
    
    func generatedTableFromArray(searchText: String) {

        filteredContents = contents.filter {(title: Content) -> Bool in
            if title.url!.lastPathComponent.lowercased().contains(searchText.lowercased()) {
                return true
            } else if searchText == "" {
                return true
            } else {
                return false
            }
        }
        sortTheContents(array: filteredContents)
    }
}
