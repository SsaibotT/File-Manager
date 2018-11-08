//
//  DirectoryController.swift
//  File Manager
//
//  Created by Serhii on 10/25/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit
import PDFKit

class DirectoryController: UITableViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UISearchBarDelegate {

    lazy var brains = Brains()

    var mySearchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if brains.path == nil {
            brains.path = URL.init(string: "file:///Users/ghjkghkj/Desktop/folder/")
        }

        brains.sortTheContents(array: brains.filteredContents)

        navigationItem.title = brains.path.lastPathComponent
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationButtons()
    }

    private func navigationButtons () {
        if navigationController!.viewControllers.count > 1 {
            let backToRoot = UIBarButtonItem.init(title: "Back To Root",
                                                  style: UIBarButtonItem.Style.plain,
                                                  target: self,
                                                  action: #selector(DirectoryController.backToRoot))

            navigationItem.rightBarButtonItem = backToRoot
        }

        let addAction = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                                             target: self,
                                             action: #selector(DirectoryController.addAction))

        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
                                         target: nil,
                                         action: nil)

        let editAction = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit,
                                              target: self,
                                              action: #selector(DirectoryController.editAction))

        let imageAction = UIBarButtonItem.init(title: "Gallery",
                                               style: UIBarButtonItem.Style.done,
                                               target: self,
                                               action: #selector(DirectoryController.imageAction))

        let arraysOfButtons = [addAction, imageAction, space, editAction]
        toolbarItems = arraysOfButtons
    }

    // MARK: Actions

    @objc private func imageAction() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        self.present(imagePickerController, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.imageURL] as? URL else { return }

        let name = brains.path.appendingPathComponent(image.lastPathComponent)

        do {
            try FileManager.default.copyItem(at: image, to: name)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        sortAndInsertRowWith(name: Content(url: name))
        picker.dismiss(animated: true, completion: nil)
    }

    @objc private func backToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func addAction() {

        let alert = UIAlertController.init(title: "Creating Folder",
                                           message: "Enter the folders name",
                                           preferredStyle: UIAlertController.Style.alert)

        alert.addTextField { (UITextField) in
            UITextField.placeholder = "folders name"
        }

        let defaultAction = UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default) {[unowned self] (_) in
            let textField = alert.textFields?.first?.text

            if textField == "" || self.brains.contents.map({$0.url!.lastPathComponent}).contains(textField) {
                let failAlert = UIAlertController(title: "Fail",
                                                  message: "Name is invalid",
                                                  preferredStyle: UIAlertController.Style.alert)
                let failAction = UIAlertAction(title: "Ok",
                                               style: UIAlertAction.Style.default,
                                               handler: {[unowned self] (_) in
                                                self.addAction()
                })
                
                failAlert.addAction(failAction)
                self.present(failAlert, animated: true, completion: nil)
                
            } else {
                let name = textField
                let path = self.brains.path.appendingPathComponent(name!)
                
                if (try? FileManager.default.createDirectory(atPath: path.path,
                                                             withIntermediateDirectories: true,
                                                             attributes: nil)) != nil {
                    self.sortAndInsertRowWith(name: Content(url: path))
                }
            }
        }
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

    @objc private func editAction() {

        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
        }
    }
    
    func sortAndInsertRowWith(name: Content) {
        brains.contents.append(name)
        
        if name.url!.lastPathComponent.contains(mySearchText) || mySearchText == "" {
            brains.filteredContents.append(name)
            
            brains.sortTheContents(array: brains.filteredContents)
            
            let row = brains.filteredContents.index(of: name)
            let indexPath1 = IndexPath.init(row: row!, section: 0)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath1], with: UITableView.RowAnimation.right)
            tableView.endUpdates()
        }
    }

    // MARK: Table view datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brains.filteredContents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "Cell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FolderAndFileCell else {
            return UITableViewCell()
        }
        
        cell.pasingInfoForButton = {
            if self.brains.filteredContents[indexPath.row].getType() == Type.directory {
                self.performSegue(withIdentifier: "folderSegue", sender: cell)
            } else {
                self.performSegue(withIdentifier: "fileSegue", sender: cell)
            }
        }
        
        cell.cellConfig(name: brains.filteredContents[indexPath.row].url!.lastPathComponent,
                        image: UIImage(named: brains.filteredContents[indexPath.row].getType().getName())!)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!) else {return}
        segue.destination.hidesBottomBarWhenPushed = true
        
        switch segue.destination {
        case is FileViewController:
            let fileName = brains.filteredContents[indexPath.row]
            
            var attributes: NSDictionary?
            do {
                attributes = try FileManager.default.attributesOfItem(atPath: fileName.url!.path) as NSDictionary
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            guard let vcontr = segue.destination as? FileViewController else {return}
            vcontr.configFileViewControl(name: fileName.url!.lastPathComponent,
                                         size: brains.casting(bytes: Double((attributes?.fileSize())!)),
                                         creationDate: "\((attributes!.fileCreationDate())!)",
                modifiedDate: "\((attributes!.fileModificationDate())!)")
            
        case is FolderViewController:
            let folderName = brains.filteredContents[indexPath.row]
            var attributes: NSDictionary?
            
            do {
                attributes = try FileManager.default
                    .attributesOfItem(atPath: folderName.url!.path) as NSDictionary
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            let folderSize = brains.casting(bytes: Double(brains
                .folderSizeAndAmount(folderPath: folderName.url!.path).0))
            guard let vcontr = segue.destination as? FolderViewController else {return}
            
            vcontr.configFolderViewControl(name: folderName.url!.lastPathComponent,
                                           size: folderSize,
                                           amountOfFiles: "\(brains.folderSizeAndAmount(folderPath: folderName.url!.path).1)",
                creationDate: "\((attributes!.fileCreationDate())!)",
                modifiedDate: "\((attributes!.fileModificationDate())!)")
        case is ImageViewController:
            var data: Data!
            
            do {
                data = try Data(contentsOf: brains.filteredContents[indexPath.row].url!)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            guard let vcontr = segue.destination as? ImageViewController else {return}
            vcontr.configImageViewController(image: UIImage(data: data!)!)
            
        case is PDFViewController:
            let document = PDFDocument(url: brains.filteredContents[indexPath.row].url!)
            guard let vcontr = segue.destination as? PDFViewController else {return}
            vcontr.configPDFViewController(document: document!)
        case is TextViewController:
            
            let textContent = brains.filteredContents[indexPath.row].typeOfText()
            guard let vcontr = segue.destination as? TextViewController else {return}
            vcontr.configTXTViewController(text: textContent)
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle != UITableViewCell.EditingStyle.delete {return}
        let name = brains.filteredContents[indexPath.row]
        
        if (try? FileManager.default.removeItem(atPath: name.url!.path)) != nil {
            
            brains.contents.remove(at: (brains.contents.map({$0.url!.lastPathComponent})
                .index(of: name.url!.lastPathComponent))!)
            brains.filteredContents.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            tableView.endUpdates()
        }
    }

    // MARK: table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch brains.filteredContents[indexPath.row].getType() {
        case .directory:
            let fileName = brains.filteredContents[indexPath.row].url!.lastPathComponent
            let path = brains.path.appendingPathComponent(fileName)
            
            let viewController: DirectoryController = (storyboard?
                .instantiateViewController(withIdentifier: "DirectoryController") as? DirectoryController)!
            
            viewController.brains.path = path
            navigationController!.pushViewController(viewController, animated: true)
        case .image:
            performSegue(withIdentifier: "imageSegue", sender: tableView.cellForRow(at: indexPath))
        case .pdfFile:
            performSegue(withIdentifier: "pdfSegue", sender: tableView.cellForRow(at: indexPath))
        case .txtFile:
            performSegue(withIdentifier: "textSegue", sender: tableView.cellForRow(at: indexPath))
        default:
            print("nothing")
        }
    }
    
    // MARK: Search bar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        mySearchText = searchText
        brains.generatedTableFromArray(searchText: searchText)
        tableView.reloadData()
    }
}
