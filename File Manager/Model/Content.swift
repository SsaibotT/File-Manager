//
//  Content.swift
//  File Manager
//
//  Created by Serhii on 11/7/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import Foundation

struct Content: Equatable {
    
    var url: URL!
    
    init(url: URL) {
        self.url = url
    }
    
    var type: Type {
        var isDirectory = ObjCBool(false)
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if isDirectory.boolValue {
            return Type.directory
        }
        
        if ["jpg", "png", "gif", "jpeg"].contains((url.pathExtension)) {
            return Type.image
        }
        
        if "pdf".contains((url.pathExtension)) {
            return Type.pdfFile
        }
        
        if ["txt", "rtf", "html"].contains((url.pathExtension)) {
            return Type.txtFile
        }
        
        return Type.file
    }
    
    func typeOfText() -> NSAttributedString {
        
        var textContent = NSAttributedString()
        switch url.pathExtension {
        case "rtf":
            textContent = chosingDocumentType(typeAttribute: .rtf, url: url)
        case "txt":
            textContent = chosingDocumentType(typeAttribute: .plain, url: url)
        case "html":
            textContent = chosingDocumentType(typeAttribute: .html, url: url)
        default:
            print("nothing")
        }
        
        return textContent
    }
    
    private func chosingDocumentType(typeAttribute: NSAttributedString.DocumentType, url: URL) -> NSAttributedString {
        guard let textContent = try?
            NSAttributedString(url: url,
                               options: [NSAttributedString
                                .DocumentReadingOptionKey
                                .documentType: typeAttribute],
                               documentAttributes: nil) else {return NSAttributedString()}
        return textContent
    }
    
    static func == (lhs: Content, rhs: Content) -> Bool {
        return lhs.url == rhs.url
    }
}
