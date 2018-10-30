//
//  DirectoryController.swift
//  File Manager
//
//  Created by Serhii on 10/25/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class DirectoryController: UITableViewController {
    
    lazy var brains = Brains(contents: contents, path: path)
    
    var indexPathOfFileButton: IndexPath?
    var indexPathOfButton: IndexPath?
    var amountOfFilesInFolder: Int?
    
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
        
        brains.sortTheConents(array: self.contents)
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
    
    @IBAction func actionInfoCell(_ sender: UIButton) {
        
        let cell: UITableViewCell? = sender.superCell()

        if cell != nil {
            
            indexPathOfButton = self.tableView.indexPath(for: cell!)
            
            if brains.isDirectoryAt(indexPath: indexPathOfButton!) {
                performSegue(withIdentifier: "folderSegue", sender: nil)
            } else {
                performSegue(withIdentifier: "fileSegue", sender: nil)
            }
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
            
            if (textField == "" || self.contents.contains(textField!)) {
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
                    tempArray = self.contents
                    tempArray.insert(name!, at: 0)
                    self.contents = tempArray
                    
                    self.brains.sortTheConents(array: self.contents)
                    
                    let row = self.contents.index(of: name!)
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
    
    // MARK: Table view datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"

        if brains.isDirectoryAt(indexPath: indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! folderAndFileCell
            cell.nameLabel.text = self.contents[indexPath.row]
            cell.cellImage.image = UIImage.init(named: "folder")

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! folderAndFileCell
            cell.nameLabel.text = self.contents[indexPath.row]
            cell.cellImage.image = UIImage.init(named: "file")

            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FileViewController {
            let fileName = self.contents[indexPathOfFileButton!.row]
            let path = self.path.appendingPathComponent(path: fileName)
            let attributes = try? FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            
            let vc = segue.destination as? FileViewController
            
            vc?.name = fileName
            vc?.size = brains.casting(bytes: Double((attributes?.fileSize())!))
            vc?.creationDate = "\((attributes!.fileCreationDate())!)"
            vc?.modifiedDate = "\((attributes!.fileModificationDate())!)"
        }
        
        if segue.destination is FolderViewController {
            let folderName = self.contents[indexPathOfButton!.row]
            let path = self.path.appendingPathComponent(path: folderName)
            let attributes = try? FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            
            let folderSize = brains.casting(bytes: Double(brains.folderSizeAndAmount(folderPath: path).0))
            
            let vc = segue.destination as? FolderViewController
            
            vc?.name = folderName
            vc?.size = folderSize
            vc?.amountOfFiles = "\(brains.folderSizeAndAmount(folderPath: path).1)"
            vc?.creationDate  = "\((attributes!.fileCreationDate())!)"
            vc?.modifiedDate  = "\((attributes!.fileModificationDate())!)"
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let name = self.contents[indexPath.row]
            let path = self.path.appendingPathComponent(path: name)
            
            var tempArray: Array<String>
            
            if ((try? FileManager.default.removeItem(atPath: path)) != nil){
                tempArray = self.contents
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
        
        if brains.isDirectoryAt(indexPath: indexPath) {
            let fileName = self.contents[indexPath.row]
            let path = self.path.appendingPathComponent(path: fileName)
            
            let viewController: DirectoryController = self.storyboard?.instantiateViewController(withIdentifier: "DirectoryController") as! DirectoryController
            viewController.path = path
            self.navigationController!.pushViewController(viewController, animated: true)
            
        }
    }
    
}



