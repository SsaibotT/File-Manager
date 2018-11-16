//
//  DirectoryController.swift
//  File Manager
//
//  Created by Serhii on 10/25/18.
//  Copyright © 2018 Serhii. All rights reserved.
//
//Запитатись за анімації при видаленні чи созданні
//Запитатись чи Variables правильно використовувати
//Запитатись шо робити з методом prepareFor

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
        searchBar.rx.text.asObservable().bind(to: directoryViewModel.searchTextObservable).disposed(by: disposeBag)
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
            self.directoryViewModel.add(name: textField!)

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
//
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
//                            forRowAt indexPath: IndexPath) {
//
//        if editingStyle != UITableViewCell.EditingStyle.delete {return}
//
//        directoryViewModel.remove(index: indexPath.row)
//
//    }
//
//    // MARK: table view delegate
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        switch brains.filteredContents[indexPath.row].getType() {
//        case .directory:
//            let fileName = brains.filteredContents[indexPath.row].url!.lastPathComponent
//            let path = brains.path.appendingPathComponent(fileName)
//
//            let viewController: DirectoryController = (storyboard?
//                .instantiateViewController(withIdentifier: "DirectoryController") as? DirectoryController)!
//
//            viewController.brains.path = path
//            navigationController!.pushViewController(viewController, animated: true)
//        case .image:
//            performSegue(withIdentifier: "imageSegue", sender: tableView.cellForRow(at: indexPath))
//        case .pdfFile:
//            performSegue(withIdentifier: "pdfSegue", sender: tableView.cellForRow(at: indexPath))
//        case .txtFile:
//            performSegue(withIdentifier: "textSegue", sender: tableView.cellForRow(at: indexPath))
//        default:
//            print("nothing")
//        }
//    }
//
//    // MARK: Search bar delegate
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        searchBar.setShowsCancelButton(false, animated: true)
//    }
//
//    //create observable for searchText
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        mySearchText = searchText
//        brains.generatedTableFromArray(searchText: searchText)
//        tableView.reloadData()
//    }
}
