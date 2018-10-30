//
//  extensions.swift
//  File Manager
//
//  Created by Serhii on 10/30/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func appendingPathComponent(path: String) -> String {
        let str = (self as NSString).appendingPathComponent(path)
        return str
    }
    
    func lastPathComponent() -> String {
        let str = (self as NSString).lastPathComponent
        return str
    }
    
}

extension UIView {
    
    func superCell() -> UITableViewCell {
        if (self.superview == nil) {
            
        }
        
        if (self.superview?.isKind(of: UITableViewCell.self))! {
            return self.superview as! UITableViewCell
        }
        
        return self.superview!.superCell()
    }
}

