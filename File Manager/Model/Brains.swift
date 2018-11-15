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

    //func sortTheContents(array: [Content]) {
    func sortTheContents() {

        var arrayOfDirectories = [Content]()
        var arrayOfFiles = [Content]()

        for content in contents {
            content.getType() == Type.directory ?
                arrayOfDirectories.append(content) :
                arrayOfFiles.append(content)
        }
        
        let sortedDictionaryArray = arrayOfDirectories.sorted {$0.url!.lastPathComponent < $1.url!.lastPathComponent}
        let sortedFilesArray = arrayOfFiles.sorted {$0.url!.lastPathComponent < $1.url!.lastPathComponent}
        filteredContents = sortedDictionaryArray + sortedFilesArray
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
    
    func formatingDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        
        let fileDate   = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let todaysDate = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        if fileDate != todaysDate {
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            return dateFormatter.string(from: date)
        }
        
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
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

        filteredContents = contents.filter {(title: Content) -> Bool in
            if title.url!.lastPathComponent.lowercased().contains(searchText.lowercased()) {
                return true
            } else if searchText == "" {
                return true
            } else {
                return false
            }
        }
        
        sortTheContents()
    }
}
