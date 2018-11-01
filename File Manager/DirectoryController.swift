//
//  DirectoryController.swift
//  File Manager
//
//  Created by Serhii on 10/25/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit

class DirectoryController: UITableViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CustomCellDelegator {

    lazy var brains = Brains()

    var indexPathOfButton: IndexPath?
    var imageURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        if brains.path == nil {
            brains.path = URL.init(string: "file:///Users/ghjkghkj/Desktop/folder/")
        }

        brains.sortTheConents(array: brains.contents!)

        navigationItem.title = brains.path.lastPathComponent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationButtons()
    }

    func navigationButtons () {
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

    @objc func imageAction() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        self.present(imagePickerController, animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController,
                                     didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.imageURL] as? URL

        let name = brains.path.appendingPathComponent((image?.lastPathComponent)!)

        do {
            try FileManager.default.copyItem(at: image!, to: name)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        var tempArray: [URL]?

        tempArray = self.brains.contents
        tempArray?.insert(name, at: 0)

        self.brains.contents = tempArray

        self.brains.sortTheConents(array: self.brains.contents!)

        let row = self.brains.contents!.index(of: name)
        let indexPath1 = IndexPath.init(row: row!, section: 0)

        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath1], with: UITableView.RowAnimation.right)
        self.tableView.endUpdates()

        picker.dismiss(animated: true, completion: nil)
    }

    @objc func backToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }

    @objc func addAction() {

        let alert = UIAlertController.init(title: "Creating Folder",
                                           message: "Enter the folders name",
                                           preferredStyle: UIAlertController.Style.alert)

        alert.addTextField { (UITextField) in
            UITextField.placeholder = "folders name"
        }

        let defaultAction = UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default) { (_) in
                let textField = alert.textFields?.first?.text

                    if textField == "" {
                        let failAlert = UIAlertController.init(title: "Fail",
                                                               message: "Name is invalid",
                                                               preferredStyle: UIAlertController.Style.alert)
                        let failAction = UIAlertAction.init(title: "Ok",
                                                            style: UIAlertAction.Style.default,
                                                            handler: { (_) in
                                                                self.addAction()
                        })

                        failAlert.addAction(failAction)
                        self.present(failAlert, animated: true, completion: nil)

                    } else {
                        let name = textField
                        let path = self.brains.path.appendingPathComponent(name!)

                        var tempArray: [URL]?

                        if (try? FileManager.default.createDirectory(atPath: path.path,
                                                                     withIntermediateDirectories: true,
                                                                     attributes: nil)) != nil {
                            tempArray = self.brains.contents
                            tempArray?.insert(path, at: 0)
                            print(path.path)
                            self.brains.contents = tempArray

                            self.brains.sortTheConents(array: self.brains.contents!)

                            let row = self.brains.contents!.index(of: path)
                            let indexPath1 = IndexPath.init(row: row!, section: 0)

                            self.tableView.beginUpdates()
                            self.tableView.insertRows(at: [indexPath1], with: UITableView.RowAnimation.right)
                            self.tableView.endUpdates()
                        }
                }
        }
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

    @objc func editAction() {

        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
        }

    }

    // MARK: Table view datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return brains.contents!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "Cell"

        if brains.isDirectoryAt(atIndexPath: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FolderAndFileCell
            cell!.nameLabel.text = brains.contents![indexPath.row].lastPathComponent
            cell!.cellImage.image = UIImage.init(named: "folder")
            cell!.delegate = self

            return cell!
        } else if brains.isImage(atIndexPath: indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FolderAndFileCell
            cell!.nameLabel.text = brains.contents![indexPath.row].lastPathComponent
            cell!.cellImage.image = UIImage.init(named: "image")
            cell?.delegate = self

            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FolderAndFileCell
            cell!.nameLabel.text = brains.contents![indexPath.row].lastPathComponent
            cell!.cellImage.image = UIImage.init(named: "file")
            cell!.delegate = self

            return cell!
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is FileViewController {
            let fileName = brains.contents![indexPathOfButton!.row]

            var attributes: NSDictionary?
            do {
                attributes = try FileManager.default.attributesOfItem(atPath: fileName.path) as NSDictionary
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            let vcontr = segue.destination as? FileViewController

            vcontr?.name = fileName.lastPathComponent
            vcontr?.size = brains.casting(bytes: Double((attributes?.fileSize())!))
            vcontr?.creationDate = "\((attributes!.fileCreationDate())!)"
            vcontr?.modifiedDate = "\((attributes!.fileModificationDate())!)"
        }

        if segue.destination is FolderViewController {
            let folderName = brains.contents![indexPathOfButton!.row]

            var attributes: NSDictionary?
            do {
                attributes = try FileManager.default.attributesOfItem(atPath: folderName.path) as NSDictionary
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            let folderSize = brains.casting(bytes: Double(brains.folderSizeAndAmount(folderPath: folderName.path).0))
            let vcontr = segue.destination as? FolderViewController

            vcontr?.name = folderName.lastPathComponent
            vcontr?.size = folderSize
            vcontr?.amountOfFiles = "\(brains.folderSizeAndAmount(folderPath: folderName.path).1)"
            vcontr?.creationDate  = "\((attributes!.fileCreationDate())!)"
            vcontr?.modifiedDate  = "\((attributes!.fileModificationDate())!)"

        }

        if segue.destination is ImageViewController {
            let url = imageURL
            var data: Data!

            do {
                data = try Data(contentsOf: url!)
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            let vcontr = segue.destination as? ImageViewController

            vcontr?.image = UIImage(data: data!)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {

        if editingStyle == UITableViewCell.EditingStyle.delete {
            let name = brains.contents![indexPath.row]
            print(name.path)

            var tempArray: [URL]?

            if (try? FileManager.default.removeItem(atPath: name.path)) != nil {

                tempArray = brains.contents
                tempArray?.remove(at: indexPath.row)
                brains.contents = tempArray

                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                tableView.endUpdates()
            }

        }

    }

    // MARK: table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if brains.isDirectoryAt(atIndexPath: indexPath.row) {
            let fileName = brains.contents![indexPath.row].lastPathComponent
            let path = brains.path.appendingPathComponent(fileName)

            let viewController: DirectoryController = (storyboard?
                .instantiateViewController(withIdentifier: "DirectoryController") as? DirectoryController)!

            viewController.brains.path = path
            navigationController!.pushViewController(viewController, animated: true)

        } else if brains.isImage(atIndexPath: indexPath.row) {
            imageURL = brains.contents![indexPath.row]
            performSegue(withIdentifier: "imageSegue", sender: nil)
        }
    }

    // MARK: Custom cell delegate

    func callSegueFromCell(sender: UIButton) {

        let cell: UITableViewCell? = sender.superCell()

        if cell != nil {

            indexPathOfButton = self.tableView.indexPath(for: cell!)

            if brains.isDirectoryAt(atIndexPath: indexPathOfButton!.row) {
                performSegue(withIdentifier: "folderSegue", sender: nil)
            } else {
                performSegue(withIdentifier: "fileSegue", sender: nil)
            }
        }
    }
}
