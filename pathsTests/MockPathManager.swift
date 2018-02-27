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
    var currentPathDriver: SharedSequence<DriverSharingStrategy, Path?>?
    var hasNewPath: Bool = false
    var currentAlbumId: String?
    var currentPathSubject : BehaviorSubject<Path?>
    
    init() {
        currentPathSubject = BehaviorSubject<Path?>(value: nil)
        currentPathDriver = currentPathSubject.asDriver(onErrorJustReturn: nil)
    }
    func updateCurrentAlbum(collectionid: String) {
    }
    func setCurrentPath(_ path: Path?) {
        currentPathSubject.onNext(path)
    }
    func savePath(start: Date, end: Date, callback: @escaping (Path?, Error?) -> Void) {
    }
    func updateCurrentPathInCoreData(notify: Bool) throws {
    }
    func addPointToData(_ point: LocalPoint) {
    }
    func clearPoints() {
    }
    func getPathsToOverlay() -> [Path]? {
        return nil
    }
}
