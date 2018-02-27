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
    weak var pathManager : IPathManager? = PathManager.shared
    var locationManager : ILocationManager?
    var startTime : Date?
    var stopTime : Date?
    var disposeBag = DisposeBag()
    
    convenience init(nibName: String?, bundle: Bundle?, locationManager: ILocationManager, pathManager: IPathManager){
        self.init(nibName: nibName, bundle: bundle)
        //self.pathManager = pathManager
        self.locationManager = locationManager
    }
    
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
}
