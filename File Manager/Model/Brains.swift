//
//  Brains.swift
//  File Manager
//
//  Created by Serhii on 10/30/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class Brains: NSObject {

    var directoryVC = DirectoryController()
    var contents: [URL]?
    var filteredContents = [URL]()
    var path: URL! {
        didSet {
            do {
                contents = try FileManager.default.contentsOfDirectory(at: path,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: FileManager
                                                                        .DirectoryEnumerationOptions
                                                                        .skipsHiddenFiles)
                filteredContents = contents!
            } catch let error as NSError {
                print(error.localizedDescription)
                contents = nil
            }
        }
    }

    func isDirectoryAt(atIndexPath: Int) -> Bool {

        var isDirectory = ObjCBool(false)
        let pathAtIndex = filteredContents[atIndexPath]
        FileManager.default.fileExists(atPath: pathAtIndex.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }

    func isImage(atIndexPath: Int) -> Bool {

        let imageFormats = ["jpg", "png", "gif", "jpeg"]
        let pathIndex = filteredContents[atIndexPath]
        let myExtension = pathIndex.pathExtension

        return imageFormats.contains(myExtension) ? true : false
    }

    func sortTheConents(array: [URL]) {

        let tempArray = array
        var arrayOfDirectories = [URL]()
        var arrayOfFiles = [URL]()

        for counter in 0..<tempArray.count {
            let index = counter
            
            isDirectoryAt(atIndexPath: index) ?
                arrayOfDirectories.append(array[counter]) :
                arrayOfFiles.append(array[counter])
        }
        let sortedDictionaryArray = arrayOfDirectories.sorted {$0.lastPathComponent < $1.lastPathComponent}
        let sortedFilesArray = arrayOfFiles.sorted {$0.lastPathComponent < $1.lastPathComponent}
        let sortedArray = sortedDictionaryArray + sortedFilesArray

        filteredContents = sortedArray
    }

    func casting(bytes: Double) -> String {
        let unit = ["B", "KB", "MB", "GB", "TB"]
        var index = 0

        var castedValue: Double = bytes

        while castedValue > 1024 && index < 5 {
            castedValue /= 1024
            index += 1
        }

        let castedToString = String(format: "%.2f", castedValue)
        return "\(castedToString) \(unit[index])"
    }

    func folderSizeAndAmount(folderPath: String) -> (UInt, Int) {

        var filesArray: [String]?

        do {
            filesArray = try FileManager.default.subpathsOfDirectory(atPath: folderPath)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        let fileAmount = filesArray!.count
        var fileSize: UInt = 0

        for fileName in filesArray! {
            let filePath = URL(fileURLWithPath: folderPath).appendingPathComponent(fileName)
            var fileDictionary: NSDictionary?
            do {
            fileDictionary = try FileManager.default.attributesOfItem(atPath: filePath.path) as NSDictionary
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            fileSize += UInt(fileDictionary!.fileSize())
        }

        return (fileSize, fileAmount)
    }
    
    func generatedTableFromArray(searchText: String) {

        var tempArray: [URL]?
        tempArray = contents!.filter {(title: URL) -> Bool in
            if title.lastPathComponent.lowercased().contains(searchText.lowercased()) {
                return true
            } else if searchText == "" {
                return true
            } else {
                return false
            }
        }
        
        filteredContents = tempArray!
        sortTheConents(array: filteredContents)
    }
}
