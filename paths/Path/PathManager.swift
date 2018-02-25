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

protocol PathManagerInterface {
    init(context: NSManagedObjectContext?)
    var currentPath : Path? {get}
    var currentPathDriver : Driver<Path?>? {get}
    var hasNewPath : Bool { get set}
    func updateCurrentAlbum(collectionid: String)
    func setCurrentPath(_ path: Path?)
    func savePath(local: LocalPath, callback: @escaping (Path?,Error?) -> Void)
    func updateCurrentPathInCoreData() throws
    func clearPoints()
    func addPointToData(_ point: LocalPoint)
}

class PathManager {
    public var currentPathDriver : Driver<Path?>?
    public var hasNewPath : Bool = false
    
    private var pointsManager : PointsManagerInterface = PointsManager()
    private var pedometer = CMPedometer()
    private var disposeBag = DisposeBag()
    private var _currentPath : Variable<Path?> = Variable(nil)
    private let currentPathSubject = BehaviorSubject<Path?>(value: nil)
    
    private weak var context : NSManagedObjectContext?
    
    private static var _shared : PathManager?
    
    class var shared : PathManager {
        if _shared == nil {
            _shared = PathManager()
        }
        
        return _shared!
    }
    
    required init(context: NSManagedObjectContext?) {
        self.context = context
        
        setup()
    }
    
    convenience init() {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        self.init(context: context)
    }
    
    convenience init(_ pointsManager: PointsManagerInterface, _ photoManager: PhotoManagerInterface) {
        self.init()
        
        self.pointsManager = pointsManager
    }
    
    private func setup(){
        currentPathDriver = currentPathSubject.flatMap{ _ in
            self._currentPath.asObservable()            
            }.asDriver(onErrorJustReturn: nil)
        
    }
    
    public var currentAlbumId : String? {
        return _currentPath.value?.albumId
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
        log.info("set current path to \(path?.displayTitle ?? "nil")")
        hasNewPath = false
        if( _currentPath.value?.identity != path?.identity){
            _currentPath.value = path
        }
    }
    
    public func savePath(local localpath: LocalPath, callback: @escaping (Path?,Error?) -> Void) {
        log.info("saveNewPath")
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()

        let path = Path(self.context!, localpath)
        
        let pointsData = self.getPointsData()
        path.pointsJSON = pointsData.json
        
        queue.async {
            group.enter()
            self.getSteps(path.startdate!, path.enddate!) { steps in
                path.stepcount = steps
                group.leave()
            }
        }
        
        queue.async {
            group.enter()
            self.getPathDistance(pointsData.array) { distance in
                path.distance = distance as NSNumber
                group.leave()
            }
        }
        
        queue.async {
            group.enter()
            self.getPathDuration(path.startdate!, path.enddate!) { duration in
                path.duration = duration
                group.leave()
            }
        }
        
        queue.async {
            group.enter()
            self.getLocality(pointsData.array){ locality in
                path.locations = locality
                group.leave()
            }
        }
        
        queue.async {
            group.enter()
            self.getSnapshot(from: path) { coverimage in
                if let coverImg = coverimage {
                    log.info("Set cover image")
                    path.coverimg = UIImagePNGRepresentation(coverImg)
                }
                
                group.leave()
            }
        }

        queue.async {
            group.wait()
            
            do{
                try self.context!.rx.update(path)
                self.setCurrentPath(path)
                self.hasNewPath = true
                callback(path, nil)
            } catch {
                log.error(error.localizedDescription)
                callback(nil, error)
            }
        }
    }
    
    private func getSnapshot(from path: Path, _ callback: @escaping (UIImage?) -> Void){
        MapViewController().getSnapshot(from: path) { snapshot, error in
            log.debug("getting map snapshot")
            guard error == nil else {
                log.error(error!.localizedDescription)
                callback(nil)
                return
            }
            
            callback(snapshot?.image)
        }
    }
    
    private func getLocality(_ points: [Point],_ callback: @escaping (String?) -> Void ) {
        //get location names
        if let point1 = points.first {
            CLGeocoder().reverseGeocodeLocation(CLLocation(point1.coordinates), completionHandler: { (placemarks, error) in
                var locationData : [String] = []
                
//                if let subarea = placemarks?[0].subAdministrativeArea {
//                    locationData.append(subarea)
//                }

                if let locality = placemarks?[0].locality {
                    locationData.append(locality)
                }
                
                if let sublocality = placemarks?[0].subLocality {
                    locationData.append(sublocality)
                }

                callback(locationData.joined(separator: ", "))
            } )
        }
    }
    
    private func getPathDuration(_ start: Date, _ end: Date,_ callback: @escaping (NSNumber) -> Void) {
        callback(DateInterval(start: start, end: end).duration as NSNumber)
    }
    
    private func getPathDistance(_ points: [Point],_ callback: @escaping (CLLocationDistance) -> Void){
        var pointDistance : (endPoint: CLLocation?, distance: CLLocationDistance) = (nil, 0.0)
        pointDistance = points.reduce(into: pointDistance, { (pointDistance, point) in
            if(pointDistance.endPoint == nil){ //first
                pointDistance.endPoint = CLLocation(point.coordinates)
            } else{
                pointDistance.distance += pointDistance.endPoint!.distance(from: CLLocation(point.coordinates))
                log.verbose("distance \(pointDistance.distance)")
            }
        })
        callback(pointDistance.distance)
    }
    
    private func getPointsData() -> (array: [Point], json: String?){
        var points : [Point] = []
        let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
        var pointsJSON : String?
        
        do {
            points = try context!.fetch(fetchRequest)
        } catch {
            log.error("error \(error)")
        }
        
        log.verbose("saving "+String(describing: points.count)+" points to new path")
        do {
            pointsJSON = String(data: try JSONEncoder().encode(points), encoding: .utf8)
            log.verbose("points: \(pointsJSON ?? "nil")")
        } catch {
            log.error("error "+error.localizedDescription)
        }
        
        return (points, pointsJSON)
    }
    
    private func getSteps(_ start: Date, _ end: Date, _ callback: @escaping (NSNumber?) -> Void){
        log.debug("get steps for range \(start.string) - \(end.string)")
        
        if #available(iOS 11.0, *) {
            let authStatus = CMMotionActivityManager.authorizationStatus()
            
            if authStatus == .authorized || authStatus == .notDetermined, CMPedometer.isStepCountingAvailable() {
                pedometer.queryPedometerData(from: start, to: end) {(data, error) -> Void in
                    var stepcount : NSNumber?
                    log.debug("get steps callback")
                    
                    if error == nil, let stepdata = data {
                        log.verbose("steps: \(stepdata.numberOfSteps)")
                        log.verbose("est distance: \(stepdata.distance ?? 0)")
                        stepcount = stepdata.numberOfSteps//Int64(truncating: stepdata.numberOfSteps)
                    } else {
                        log.error("error: \(error?.localizedDescription ?? "error") or step data was nil")
                    }
                    
                    callback(stepcount)
                }
            } else {
                log.error("Core motion is not authorized or step counting is not available")
                callback(nil)
            }
        } else {
            // Fallback on earlier versions
            log.debug("core motion skipped due to iOS version")
            callback(nil)
        }
        
        return
    }
    
    public func addPointToData(_ point: LocalPoint) {
        log.info("append point")
        pointsManager.savePoint(point)
    }
    
    public func clearPoints() {
        log.info("clear points")
        pointsManager.clearPoints()
    }
    
    public func updateCurrentPathInCoreData(notify: Bool = true) throws {
        log.info("call to update current path")
        
        guard let currentpath = _currentPath.value else {
            log.error("currentpath value is nil")
            return
        }
        
        log.debug("update current path in managedObjectContext")
        try context!.rx.update(currentpath)
        
        if(notify){
            currentPathSubject.onNext(currentpath) //necessary?
        }
    }
}

