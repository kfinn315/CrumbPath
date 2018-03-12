//
//  MockPathManager.swift
//  pathsTests
//
//  Created by Kevin Finn on 2/27/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import RxSwift
import RxCocoa
@testable import paths

class MockPathManager : IPathManager {
    func getNewPath() -> Path {
        return Path()
    }
    
    func save(path: Path?, callback: @escaping (Path?, Error?) -> Void) {
        
    }
    
    var currentPathObservable: Observable<Path?>?
    
    var currentPathDriver: SharedSequence<DriverSharingStrategy, Path?>?
    var hasNewPath: Bool = false
    var currentAlbumId: String?
    var currentPathSubject : BehaviorSubject<Path?>
    
    init() {
        currentPathSubject = BehaviorSubject<Path?>(value: nil)
        currentPathDriver = currentPathSubject.asDriver(onErrorJustReturn: nil)
    }
    func updateCurrentAlbum(collectionid: String) {
        mockcallback?("updateCurrentAlbum", ["collectionid":collectionid])
    }
    func setCurrentPath(_ path: Path?) {
        currentPathSubject.onNext(path)
    }
    func savePath(start: Date, end: Date, callback: @escaping (Path?, Error?) -> Void) {
        mockcallback?("savePath", ["start":start,"end":end,"callback":callback])
    }
    func updateCurrentPathInCoreData(notify: Bool) throws {
        mockcallback?("updateCurrentPathInCoreData",["notify":notify])
    }
    func addPointToData(_ point: LocalPoint) {
        mockcallback?("addPointToData",["point":point])
    }
    func clearPoints() {
        mockcallback?("clearPoints",nil)
    }
    func getAllPaths() -> [Path]? {
        mockcallback?("getRecentPaths",nil)
        return nil
    }
    
    /// method called when any of the mock methods are called
    public var mockcallback : ((String, [String:Any]?) -> ())?
}
