//
//  MyLocationManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/30/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

protocol LocationManagerInterface {
    var authorized : Driver<Bool> {get}
    var location : Driver<CLLocation> {get}
    var isUpdating : Bool { get }
    var accuracy : LocationAccuracy { get }
    func startLocationUpdates(with accuracy: LocationAccuracy)
    func stopLocationUpdates()
}

public enum LocationAccuracy : Int {
    case walking
    case running
    case biking
    case driving
    case custom
}

class LocationManager: NSObject, LocationManagerInterface, CLLocationManagerDelegate {
    static let sharedInstance = LocationManager()
    public var authorized : Driver<Bool>
    public var location : Driver<CLLocation>
    public var accuracy : LocationAccuracy = .walking
    private var updating = false
    private var disposeBag = DisposeBag()
    
    private let clLocationManager = CLLocationManager()
    
    internal override init() {
        weak var weakLocationManager = clLocationManager
        
        authorized = Observable.deferred {
            let status = CLLocationManager.authorizationStatus()
            guard let strongLocationManager = weakLocationManager else {
                return Observable.just(status)
            }
            return strongLocationManager.rx.didChangeAuthorizationStatus.startWith(status)
        }.asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedWhenInUse: return true
                case .authorizedAlways: return true
                default: return false
            }
        }
        
        location = clLocationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
          //  .filter { $0.count > 0 }
            .map { $0.last! }
        
        super.init()
        
        clLocationManager.requestAlwaysAuthorization()
        
        if(LocationSettings.significantUpdatesOn && !CLLocationManager.significantLocationChangeMonitoringAvailable()) {
            LocationSettings.significantUpdatesOn  = false
        }
    }

    private func updateSettings(_ accuracy: LocationAccuracy) {
        self.accuracy = accuracy
        
        switch accuracy {
        case .walking:
            clLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            clLocationManager.distanceFilter = 50.0 //meters
        case .running:
            clLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            clLocationManager.distanceFilter = 50.0 //meters
        case .biking:
            clLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            clLocationManager.distanceFilter = 100.0
        case .driving:
            clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            clLocationManager.distanceFilter = 1000.0 //meters
        case .custom:
            clLocationManager.desiredAccuracy = LocationSettings.locationAccuracy
            clLocationManager.distanceFilter = LocationSettings.minimumDistance
        }
        
        clLocationManager.allowsBackgroundLocationUpdates = LocationSettings.backgroundLocationUpdatesOn
        if(LocationSettings.significantUpdatesOn) {
            clLocationManager.startMonitoringSignificantLocationChanges()
        } else {
            clLocationManager.stopMonitoringSignificantLocationChanges()
        }
    }

    public func startLocationUpdates(with accuracy: LocationAccuracy = .walking) {
        updateSettings(accuracy)
        
        updating = true
        log.debug("start Location Updates()")
        clLocationManager.startUpdatingLocation()
    }
    
    public var isUpdating : Bool {
        return updating
    }    
    
    public func stopLocationUpdates() {
        clLocationManager.allowsBackgroundLocationUpdates = false
        clLocationManager.stopMonitoringSignificantLocationChanges()
        clLocationManager.stopUpdatingLocation()

        log.debug("Stop location updates")
        updating = false
    }
}
