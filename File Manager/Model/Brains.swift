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
    var contents: [String] = [""]
    var path: String! {
        didSet {
            do {
                contents = try FileManager.default.contentsOfDirectory(atPath: path)
            } catch let error as NSError {
                print(error.localizedDescription)
                contents = [""]
            }
            
            var tempArray = [String]()
            for i in contents {
                if i != ".DS_Store" {
                    tempArray.append(i)
                }
            }
            
            contents = tempArray
        }
    }
    
    func isDirectoryAt(indexPath: IndexPath) -> Bool{
        let fileName = contents[indexPath.row]
        let filePath = path.appendingPathComponent(path: fileName)
        
        var isDirectory = ObjCBool(false)
        FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
        
        return isDirectory.boolValue
    }
    
    func sortTheConents(array: Array<String>) {
        
        let tempArray = array
        var arrayOfDirectories = [String]()
        var arrayOfFiles = [String]()
        
        for i in 0..<tempArray.count {
            let index = IndexPath.init(row: i, section: 0)
            if isDirectoryAt(indexPath: index) {
                arrayOfDirectories.append(array[i])
            } else {
                arrayOfFiles.append(array[i])
            }
        }
        
        let sortedArray = arrayOfDirectories.sorted{$0 < $1} + arrayOfFiles.sorted{$0 < $1}
        contents = sortedArray
        
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
    
    func folderSizeAndAmount(folderPath:String) -> (UInt, Int){
        
        let filesArray:[String] = try! FileManager.default.subpathsOfDirectory(atPath: folderPath)
        let fileAmount = filesArray.count
        var fileSize:UInt = 0
        
        for fileName in filesArray{
            let filePath = folderPath.appendingPathComponent(path: fileName)
            let fileDictionary:NSDictionary = try! FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            fileSize += UInt(fileDictionary.fileSize())
        }
        
        return (fileSize, fileAmount)
    }
}
