//
//  DirectoryController.swift
//  File Manager
//
//  Created by Serhii on 10/25/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import UIKit
import PDFKit
import RxSwift
import RxCocoa

class DirectoryController: UITableViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    lazy var directoryViewModel = DirectoryViewModel()
    let disposeBag = DisposeBag()

    var mySearchText = ""
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil

        directoryViewModel.loaded()
        
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationButtons()
    }
    
    private func setupBindings() {
        directoryViewModel.filteredContents
            .asObservable()
            .bind(to: tableView.rx
                .items(cellIdentifier: "Cell", cellType: FolderAndFileCell.self)) {(_, content, cell) in
                cell.pasingInfoForButton = { [unowned self] in
                    if content.getType() == Type.directory {
                        self.performSegue(withIdentifier: "folderSegue", sender: cell)
                    } else {
                        self.performSegue(withIdentifier: "fileSegue", sender: cell)
                    }
                }
                
                cell.cellConfig(name: content.url!.lastPathComponent,
                                image: UIImage(named: content.getType().getType)!)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe { [unowned self] in
                self.directoryViewModel.delete(index: $0.element!.row)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe { [unowned self] in
                switch self.directoryViewModel.filteredContents.value[$0.element!.row].getType() {
                case .directory:
                    let fileName = self.directoryViewModel
                        .filteredContents.value[$0.element!.row].url!.lastPathComponent
                    let path = self.directoryViewModel.brains.path.appendingPathComponent(fileName)
                    
                    let viewController: DirectoryController = (self.storyboard?
                        .instantiateViewController(withIdentifier: "DirectoryController") as? DirectoryController)!
            
                    viewController.directoryViewModel.brains.path = path
                    self.navigationController!.pushViewController(viewController, animated: true)
                case .image:
                    self.performSegue(withIdentifier: "imageSegue", sender: self.tableView.cellForRow(at: $0.element!))
                case .pdfFile:
                    self.performSegue(withIdentifier: "pdfSegue", sender: self.tableView.cellForRow(at: $0.element!))
                case .txtFile:
                    self.performSegue(withIdentifier: "textSegue", sender: self.tableView.cellForRow(at: $0.element!))
                default:
                    print("nothing")
                }
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .subscribe { [unowned self] in
                print("im begining diting")
                self.searchBar.setShowsCancelButton(true, animated: true)
            }
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .orEmpty
            .subscribe(onNext: { [unowned self] in
                self.directoryViewModel.brains.generatedTableFromArray(searchText: $0)
                self.directoryViewModel.update()
                self.directoryViewModel.searchText = $0
                
            }).disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .subscribe { [unowned self] in
                print("im clicking cancel button")
                self.searchBar.resignFirstResponder()
                self.searchBar.setShowsCancelButton(false, animated: true)
            }
            .disposed(by: disposeBag)
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

        directoryViewModel.addImage(nameUrl: image)
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
            
            if textField == "" || self.directoryViewModel.filteredContents.value.map({$0.url!.lastPathComponent}).contains(textField) {
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
                self.directoryViewModel.add(name: textField!)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let indexPath = tableView.indexPath(for: (sender as? UITableViewCell)!) else {return}
        segue.destination.hidesBottomBarWhenPushed = true

        switch segue.destination {
        case let vcontr as FileViewController:
            let fileName = directoryViewModel.brains.filteredContents[indexPath.row]

            var attributes: NSDictionary?
            do {
                attributes = try FileManager.default.attributesOfItem(atPath: fileName.url!.path) as NSDictionary
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            vcontr.configFileViewControl(name: fileName.url!.lastPathComponent,
                                         size: directoryViewModel.brains.casting(bytes: Double((attributes?.fileSize())!)),
                                         creationDate: directoryViewModel.brains.formatingDate(date: (attributes?.fileCreationDate())!),
                modifiedDate: directoryViewModel.brains.formatingDate(date: (attributes?.fileModificationDate())!))

        case let vcontr as FolderViewController: 
            let folderName = directoryViewModel.brains.filteredContents[indexPath.row]
            var attributes: NSDictionary?

            do {
                attributes = try FileManager.default
                    .attributesOfItem(atPath: folderName.url!.path) as NSDictionary

            } catch let error as NSError {
                print(error.localizedDescription)
            }

            let folderSize = directoryViewModel.brains.casting(bytes: Double(directoryViewModel.brains
                .folderSizeAndAmount(folderPath: folderName.url!.path).0))
            vcontr.configFolderViewControl(name: folderName.url!.lastPathComponent,
                                           size: folderSize,
                                           amountOfFiles: "\(directoryViewModel.brains.folderSizeAndAmount(folderPath: folderName.url!.path).1)",
                creationDate: directoryViewModel.brains.formatingDate(date: (attributes?.fileCreationDate())!),
                modifiedDate: directoryViewModel.brains.formatingDate(date: (attributes?.fileModificationDate())!))
        case let vcontr as ImageViewController:
            var data: Data!

            do {
                data = try Data(contentsOf: directoryViewModel.filteredContents.value[indexPath.row].url!)
            } catch let error as NSError {
                print(error.localizedDescription)
            }

            vcontr.configImageViewController(image: UIImage(data: data!)!)

        case let vcontr as PDFViewController:
            let document = PDFDocument(url: directoryViewModel.filteredContents.value[indexPath.row].url!)
            vcontr.configPDFViewController(document: document!)
        case let vcontr as TextViewController:

            let textContent = directoryViewModel.filteredContents.value[indexPath.row].typeOfText()
            vcontr.configTXTViewController(text: textContent)
        default:
            break
        }
    }
}
