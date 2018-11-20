//
//  File.swift
//  File Manager
//
//  Created by Serhii on 11/18/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import Foundation

class Helper {
    
    static func casting(bytes: Double) -> String {
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
    
    static func formatingDate(date: Date) -> String {
        
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
    
    static func folderSizeAndAmount(folderPath: String) -> (UInt, Int) {
        
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
}
