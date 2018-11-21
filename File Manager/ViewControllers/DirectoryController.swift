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

    var directoryViewModel: DirectoryViewModel!
    let disposeBag = DisposeBag()
    var path: URL!

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil

        if path == nil {
            path = URL.init(string: "file:///Users/ghjkghkj/Desktop/folder/")
        }
        directoryViewModel = DirectoryViewModel(path: path)
        
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
                    if content.type == Type.directory {
                        guard let indexPath = self.tableView.indexPath(for: (cell)) else {return}
                        self.goToFolderInfo(indexPath: indexPath, viewController: self)
                    } else {
                        guard let indexPath = self.tableView.indexPath(for: (cell)) else {return}
                        self.goToFileInfo(indexPath: indexPath, viewController: self)
                    }
                }
                
                cell.cellConfig(name: content.url.lastPathComponent,
                                image: UIImage(named: content.type.rawValue)!)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [unowned self] in
                self.directoryViewModel.delete(index: $0.row)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] in
                guard let cell = self.tableView.cellForRow(at: $0) else {return}
                guard let indexPath = self.tableView.indexPath(for: (cell)) else {return}
                
                switch self.directoryViewModel.filteredContents.value[$0.row].type {
                case .directory:
                    self.goToDirectoryViewController(indexPath: indexPath,
                                                     viewController: self)
                case .image:
                    self.goToImageViewController(indexPath: indexPath,
                                                 viewController: self)
                case .pdfFile:
                    self.goToPDFViewController(indexPath: indexPath,
                                               viewController: self)
                case .txtFile:
                    self.goToTextViewController(indexPath: indexPath,
                                                viewController: self)
                case .file:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .subscribe(onNext: { [unowned self] in
                self.searchBar.setShowsCancelButton(true, animated: true)
            })
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .asObservable()
            .bind(to: directoryViewModel.searchText)
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [unowned self] in
                self.searchBar.resignFirstResponder()
                self.searchBar.setShowsCancelButton(false, animated: true)
            })
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
            guard let textField = alert.textFields?.first?.text else {return}
            let mapingFilteredContents = self.directoryViewModel.filteredContents.value.map({$0.url.lastPathComponent})
            
            if textField == "" || mapingFilteredContents.contains(textField) {
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
                self.directoryViewModel.add(name: textField)
            }
        }
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }

    @objc private func editAction() {

        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    // MARK: Opening View ViewControllers
    
    func goToFolderInfo(indexPath: IndexPath,
                        viewController: UIViewController) {
        
        let folderName = directoryViewModel.filteredContents.value[indexPath.row]
        var attributes: NSDictionary!
        do {
            attributes = try FileManager.default
                .attributesOfItem(atPath: folderName.url.path) as NSDictionary
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let folderSize = Helper.casting(bytes: Double(Helper
            .folderSizeAndAmount(folderPath: folderName.url.path).0))
        let folderAmoundOfFiles = "\(Helper.folderSizeAndAmount(folderPath: folderName.url.path).1)"
        let creationDate = Helper.formatingDate(date: (attributes.fileCreationDate())!)
        let modifiedDate = Helper.formatingDate(date: (attributes.fileModificationDate())!)
        
        ShowControllers.showDetailFolderViewController(from: viewController,
                                                       name: folderName.url.lastPathComponent,
                                                       size: folderSize,
                                                       amountOfFiles: folderAmoundOfFiles,
                                                       creationDate: creationDate,
                                                       modifiedDate: modifiedDate)
    }
    
    func goToFileInfo(indexPath: IndexPath,
                      viewController: UIViewController) {
        
        let fileName = directoryViewModel.filteredContents.value[indexPath.row]
        var attributes: NSDictionary!
        do {
            attributes = try FileManager.default.attributesOfItem(atPath: fileName.url.path) as NSDictionary
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let fileSize     = Helper.casting(bytes: Double((attributes?.fileSize())!))
        let creationDate = Helper.formatingDate(date: (attributes.fileCreationDate())!)
        let modifiedDate = Helper.formatingDate(date: (attributes.fileModificationDate())!)
        
        ShowControllers.showDetailFileViewController(from: viewController,
                                                     name: fileName.url.lastPathComponent,
                                                     size: fileSize,
                                                     creationDate: creationDate,
                                                     modifiedDate: modifiedDate)
    }
    
    func goToImageViewController(indexPath: IndexPath,
                                 viewController: UIViewController) {
        var data: Data!
        
        do {
            data = try Data(contentsOf: directoryViewModel.filteredContents.value[indexPath.row].url)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        ShowControllers.showImageViewController(from: viewController,
                                                image: UIImage(data: data)!)
        
    }
    
    func goToPDFViewController(indexPath: IndexPath,
                               viewController: UIViewController) {
        guard let document = PDFDocument(url: directoryViewModel.filteredContents.value[indexPath.row].url) else {return}
        ShowControllers.showPDFViewController(from: viewController,
                                              document: document)
    }
    
    func goToDirectoryViewController(indexPath: IndexPath,
                                     viewController: UIViewController) {
        
        let fileName = directoryViewModel.filteredContents.value[indexPath.row].url.lastPathComponent
        let path = self.directoryViewModel.path.appendingPathComponent(fileName)
        ShowControllers.showDirectoryViewController(from: viewController, path: path)
    }
    
    func goToTextViewController(indexPath: IndexPath,
                                viewController: UIViewController) {
        
        let textContent = directoryViewModel.filteredContents.value[indexPath.row].typeOfText()
        ShowControllers.showTextViewController(from: viewController,
                                               text: textContent)
    }
}
