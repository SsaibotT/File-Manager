//
//  DirectoryController.swift
//  File Manager
//
//  Created by Serhii on 10/25/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class DirectoryController: UITableViewController {
    
    var indexPathOfFileButton: IndexPath?
    var indexPathOfFolderButton: IndexPath?
    var amountOfFilesInFolder: Int?
    
    var contents: [String]?
    var path: String! {
        didSet {
            do {
                contents = try FileManager.default.contentsOfDirectory(atPath: path)
            } catch let error as NSError {
                print(error.localizedDescription)
                contents = nil
            }
            
            var tempArray = [String]()
            for i in contents! {
                if i != ".DS_Store" {
                    tempArray.append(i)
                }
            }

            self.contents = tempArray
            
            self.tableView.reloadData()
            self.navigationItem.title = path.lastPathComponent()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.path == nil {
            self.path = "/Users/ghjkghkj/Desktop/folder/"
        }
        
        self.sortTheConents(array: self.contents!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController!.viewControllers.count > 1 {
            let backToRoot = UIBarButtonItem.init(title: "Back To Root",
                                                  style: UIBarButtonItem.Style.plain,
                                                  target: self,
                                                  action: #selector(DirectoryController.backToRoot))
            
            self.navigationItem.rightBarButtonItem = backToRoot
        }
        
        let addAction = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                             target: self,
                                             action: #selector(DirectoryController.addAction))
        
        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let editAction = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit,
                                              target: self,
                                              action: #selector(DirectoryController.editAction))
        
        let arraysOfButtons = [addAction, space, editAction]
        self.toolbarItems = arraysOfButtons
        
    }
    
    // MARK: Actions
    
    @IBAction func actionInfoCellForFolders(_ sender: UIButton) {
        
        let cell: UITableViewCell? = sender.superCell()

        if cell != nil {
            
            self.indexPathOfFolderButton = self.tableView.indexPath(for: cell!)
            
        }
    }
    
    @IBAction func actionInfoCellForFiles(_ sender: UIButton) {
        
        let cell: UITableViewCell? = sender.superCell()
        
        if cell != nil {
            
            self.indexPathOfFileButton = self.tableView.indexPath(for: cell!)
            
        }
    }
    
    @objc func backToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func addAction() {
        
        let alert = UIAlertController.init(title: "Creating Folder", message: "Enter the folders name", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (UITextField) in
            UITextField.placeholder = "folders name"
        }
        
        let defaultAction = UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default) { (alertAction) in
            let textField = alert.textFields?.first?.text
            
            if (textField == "" || self.contents!.contains(textField!)) {
                let FailAlert = UIAlertController.init(title: "Fail", message: "Name is invalid", preferredStyle: UIAlertController.Style.alert)
                let failAction = UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                    self.addAction()
                })
                
                FailAlert.addAction(failAction)
                self.present(FailAlert, animated: true, completion: nil)
                
            } else {
                let name = textField
                let path = self.path.appendingPathComponent(path: name!)
                
                var tempArray: Array<String>
                
                if (try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)) != nil {
                    tempArray = self.contents!
                    tempArray.insert(name!, at: 0)
                    self.contents = tempArray
                    
                    self.sortTheConents(array: self.contents!)
                    
                    let row = self.contents!.index(of: name!)
                    let IndexPath1 = IndexPath.init(row: row!, section: 0)
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath1], with: UITableView.RowAnimation.right)
                    self.tableView.endUpdates()
                }
                
            }
            
        }
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func editAction() {
        
        if self.tableView.isEditing == true {
            self.tableView.setEditing(false, animated: true)
        } else {
            self.tableView.setEditing(true, animated: true)
        }
        
    }
    
    func isDirectoryAt(indexPath: IndexPath) -> Bool{
        let fileName = self.contents![indexPath.row]
        let filePath = self.path.appendingPathComponent(path: fileName)
        
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
            if self.isDirectoryAt(indexPath: index) {
                arrayOfDirectories.append(array[i])
            } else {
                arrayOfFiles.append(array[i])
            }
        }
        
        let sortedArray = arrayOfDirectories.sorted{$0 < $1} + arrayOfFiles.sorted{$0 < $1}
        self.contents = sortedArray

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
    
    func folderSize(folderPath:String) -> UInt{
        
        let filesArray:[String] = try! FileManager.default.subpathsOfDirectory(atPath: folderPath)
        self.amountOfFilesInFolder = filesArray.count
        var fileSize:UInt = 0
        
        for fileName in filesArray{
            let filePath = folderPath.appendingPathComponent(path: fileName)
            let fileDictionary:NSDictionary = try! FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            fileSize += UInt(fileDictionary.fileSize())
        }
        
        return fileSize
    }
    
    // MARK: Table view datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellFolderIdentifier = "FolderCell"
        let CellFileIdentifier   = "FileCell"
        
        if self.isDirectoryAt(indexPath: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellFolderIdentifier) as! folderCells
            cell.nameLabel.text = self.contents![indexPath.row]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellFileIdentifier) as! fileCells
            cell.nameLabel.text = self.contents![indexPath.row]
            
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FileViewController {
            let fileName = self.contents![self.indexPathOfFileButton!.row]
            let path = self.path.appendingPathComponent(path: fileName)
            let attributes = try? FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            
            let vc = segue.destination as? FileViewController
            
            vc?.name = self.contents![self.indexPathOfFileButton!.row]
            vc?.size = self.casting(bytes: Double((attributes?.fileSize())!))
            vc?.creationDate = "\((attributes!.fileCreationDate())!)"
            vc?.modifiedDate = "\((attributes!.fileModificationDate())!)"
        }
        
        if segue.destination is FolderViewController {
            let folderName = self.contents![self.indexPathOfFolderButton!.row]
            let path = self.path.appendingPathComponent(path: folderName)
            let attributes = try? FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            
            let folderSize = self.casting(bytes: Double(self.folderSize(folderPath: path)))
            
            let vc = segue.destination as? FolderViewController
            
            vc?.name = folderName
            vc?.size = folderSize
            vc?.amountOfFiles = "\(self.amountOfFilesInFolder!)"
            vc?.creationDate  = "\((attributes!.fileCreationDate())!)"
            vc?.modifiedDate  = "\((attributes!.fileModificationDate())!)"
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let name = self.contents![indexPath.row]
            let path = self.path.appendingPathComponent(path: name)
            
            var tempArray: Array<String>
            
            if ((try? FileManager.default.removeItem(atPath: path)) != nil){
                tempArray = self.contents!
                tempArray.remove(at: indexPath.row)
                self.contents = tempArray
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                self.tableView.endUpdates()
            }
            
        }
        
    }
    
    //MARK: table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.isDirectoryAt(indexPath: indexPath) {
            let fileName = self.contents![indexPath.row]
            let path = self.path.appendingPathComponent(path: fileName)
            
            let viewController: DirectoryController = self.storyboard?.instantiateViewController(withIdentifier: "DirectoryController") as! DirectoryController
            viewController.path = path
            self.navigationController!.pushViewController(viewController, animated: true)
            
        }
    }
    
}

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


