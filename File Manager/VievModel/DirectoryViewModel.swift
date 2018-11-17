//
//  DirectoryViewModel.swift
//  File Manager
//
//  Created by Serhii on 11/11/18.
//  Copyright © 2018 Serhii. All rights reserved.
//

import Foundation
import RxSwift

class DirectoryViewModel {
    
    lazy var brains = Brains()
    var filteredContents: Variable<[Content]> = Variable([Content]())
    var path: URL!
    
    var searchTextObservable: BehaviorSubject<String?> = BehaviorSubject(value: "")
    var disposeBag = DisposeBag()
    
    func loaded() {
        if brains.path == nil {
            brains.path = URL.init(string: "file:///Users/ghjkghkj/Desktop/folder/")
        }
//        brains.sortTheContents()
//        filteredContents.value = brains.filteredContents
        update()
    }
    
    init() {
        searchTextObservable.subscribe(onNext: {
            print($0!)
        }).disposed(by: disposeBag)
    }
    
    func delete(index: Int) {
        let name = filteredContents.value[index]
        if (try? FileManager.default.removeItem(atPath: name.url!.path)) != nil {
            brains.contents.remove(at: (brains.contents.map({$0.url!.lastPathComponent})
                .index(of: name.url!.lastPathComponent))!)
            brains.filteredContents.remove(at: index)
            update()
        }
    }
    
    func add(name: String) {
        let path = brains.path.appendingPathComponent(name)
        
        //            if textField == "" || self.brains.contents.map({$0.url!.lastPathComponent}).contains(textField) {
        //                let failAlert = UIAlertController(title: "Fail",
        //                                                  message: "Name is invalid",
        //                                                  preferredStyle: UIAlertController.Style.alert)
        //                let failAction = UIAlertAction(title: "Ok",
        //                                               style: UIAlertAction.Style.default,
        //                                               handler: {[unowned self] (_) in
        //                                                self.addAction()
        //                })
        //
        //                failAlert.addAction(failAction)
        //                self.present(failAlert, animated: true, completion: nil)
        //
        
        if (try? FileManager.default.createDirectory(atPath: path.path,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)) != nil {
            brains.contents.append(Content(url: path))
            //brains.sortTheContents()
            update()
        }
    }
    
    func addImage(nameUrl: URL) {
        
        let path = brains.path.appendingPathComponent(nameUrl.lastPathComponent)
        
        do {
            try FileManager.default.copyItem(at: nameUrl, to: path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        print(path)
        brains.contents.append(Content(url: path))
        update()
    }
    
    func update() {
        brains.sortTheContents()
        filteredContents.value = brains.filteredContents
    }
}
