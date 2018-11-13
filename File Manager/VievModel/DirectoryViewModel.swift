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
    var contents = [Content]()
    var path: URL!
    var searchTextObservable: BehaviorSubject<String?> = BehaviorSubject(value: "")
    var disposeBag = DisposeBag()
    
    init() {
        if brains.path == nil {
            brains.path = URL.init(string: "file:///Users/ghjkghkj/Desktop/folder/")
        }
        
        brains.sortTheContents(array: brains.filteredContents)
        path = brains.path
        
        searchTextObservable.subscribe(onNext: {print($0!)}).disposed(by: disposeBag)
    }
}
