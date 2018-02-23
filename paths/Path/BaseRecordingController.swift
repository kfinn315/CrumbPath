//
//  RecordViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/7/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData
import CloudKit
import RxCocoa
import RxSwift

public class BaseRecordingController : UIViewController,CLLocationManagerDelegate {
    weak var pathManager = PathManager.shared
    var locationManager : LocationManager?
    var startTime : Date?
    var stopTime : Date?
    var isRecording : Bool = false
    
    var disposeBag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = LocationManager()
        locationManager?.location
            .drive(onNext: { [unowned self] (cllocation : CLLocation) in
                //this is called when there's a new location
                log.debug("location manager didUpdateLocations")
                
                self.pathManager?.addPointToData(LocalPoint.from(cllocation))
            }).disposed(by: disposeBag)       
    }
    public func save(callback: @escaping (Path?,Error?) -> Void) {
        let path = LocalPath()
        path.startdate = startTime ?? Date()
        path.enddate = stopTime ?? Date()
        path.title = ""
        path.notes = ""
        
        pathManager?.savePath(local: path, callback: callback)
    }
    
    public func reset() {
        pathManager?.clearPoints()
    }
    
    func startUpdating(accuracy: LocationAccuracy) {
        pathManager?.clearPoints()
        
        locationManager?.startLocationUpdates(with: accuracy)
        
        startTime = Date()
        stopTime = nil
    }
    
    public func stopUpdating() {
        stopTime = Date()
        locationManager?.stopLocationUpdates()
    }
}
