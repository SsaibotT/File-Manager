//
//  Type.swift
//  File Manager
//
//  Created by Serhii on 11/8/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import Foundation

enum Type {
    case directory
    case pdfFile
    case txtFile
    case file
    case image
    
    var getType: String {
        switch self {
        case .directory:
            return "folder"
        case .pdfFile:
            return "pdf"
        case .txtFile:
            return "txt"
        case .image:
            return "image"
        default:
            return "file"
        }
    }
}
