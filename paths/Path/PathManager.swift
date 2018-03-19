//
//  PathManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/9/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UIKit
import CoreMotion
import RxCocoa
import RxSwift
import RxCoreData
import Photos

protocol IPathManager : AnyObject {
    var currentPathObservable : Observable<Path?>? {get}
    var hasNewPath : Bool {get set}
 //   var currentAlbumId : String? {get}
    func updateCurrentAlbum(collectionid: String)
    func setCurrentPath(_ path: Path?)
    func getNewPath() -> Path
    func save(path: Path?, callback: @escaping (Path?,Error?) -> Void)
    func updateCurrentPathInCoreData(notify: Bool) throws 
    func getAllPaths() -> [Path]?
   // var hasChanges : Bool {get}
}

/**
 Manages the retrieval and updating of Paths in CoreData and sets the current Path
 */
class PathManager : IPathManager {
    public var currentPathObservable : Observable<Path?>?
    public var hasNewPath : Bool = false
    
    private var pointsManager : PointsManagerInterface = PointsManager()
    public static var pedometer = CMPedometer()
    private var disposeBag = DisposeBag()
    fileprivate var _currentPath : Variable<Path?> = Variable(nil)
    private let currentPathSubject = BehaviorSubject<Path?>(value: nil)
    
    private static var _shared : PathManager?
    public static var managedObjectContext : NSManagedObjectContext!
    
    class var shared : PathManager {
        if _shared == nil {
            _shared = PathManager()
        }
        
        return _shared!
    }
    
    required init() {
        setup()
    }
    
    convenience init(_ pointsManager: PointsManagerInterface, _ photoManager: PhotoManagerInterface) {
        self.init()
        
        self.pointsManager = pointsManager
    }
    
    private func setup(){
        currentPathObservable = currentPathSubject.flatMap{ _ in
            self._currentPath.asObservable()
            }.observeOn(ConcurrentDispatchQueueScheduler.init(qos: .userInitiated))
    }
    
    public func getNewPath() -> Path {
        return Path()
    }
    
    public func updateCurrentAlbum(collectionid: String) {
        guard _currentPath.value != nil else {
            return
        }

        self._currentPath.value?.updatePhotoAlbum(collectionid: collectionid)

        do{
            try updateCurrentPathInCoreData(notify: false)
        } catch{
            log.error(error.localizedDescription)
        }
    }
    
    public var currentPath: Path? {
        return _currentPath.value
    }
    
    public func setCurrentPath(_ path: Path?) {
        hasNewPath = false
        if( _currentPath.value?.identity != path?.identity){
            _currentPath.value = path
        }
    }
    
    public func save(path: Path?, callback: @escaping (Path?,Error?) -> Void) {
        guard let path = path else {
            callback(nil, LocalError.failed(message: "Path was nil"))
            return
        }
        
        let points = pointsManager.fetchPoints()
        path.setPoints(points)
        
        PathManager.managedObjectContext?.insert(path)
        
        //            try self.context!.rx.update(path)
        self.setCurrentPath(path)
        self.hasNewPath = true
        callback(path, nil)
    }
   
    public func updateCurrentPathInCoreData(notify: Bool = true) throws {
        log.info("call to update current path")
        
        guard let currentpath = _currentPath.value else {
            log.error("currentpath value is nil")
            return
        }
        
        log.debug("update current path in managedObjectContext")
        try PathManager.managedObjectContext!.rx.update(currentpath)
        
        if(notify){
            currentPathSubject.onNext(currentpath) //necessary?
        }
    }
    
    public func getAllPaths() -> [Path]?{
        let request: NSFetchRequest<Path> = Path.fetchRequest()
        //        let predicate = NSPredicate(format: "distance > %d", 5)
        //        request.predicate = predicate
        do{
            let result = try PathManager.managedObjectContext?.fetch(request)
            return result
        } catch{
            //error
            log.error(error.localizedDescription)
        }
        
        return nil
    }
    
    public var pathCount : Int {
        var count : Int? = 0

        do{
            
            let request: NSFetchRequest<Path> = Path.fetchRequest()
            count = try PathManager.managedObjectContext?.count(for: request)
        } catch{
            log.error(error.localizedDescription)
        }
        
        return count ?? 0
    }
}
