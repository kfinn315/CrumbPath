//
//  MapViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import Photos
import RxSwift
import RxCocoa

/**
 ViewController that displays the current Path and photo collection in a MapView object
 */
class MapViewController: UIViewController {
    public static let storyboardID = "MapVC"
    
    @IBOutlet weak var mapView: MapView!
    
    private weak var pathManager = PathManager.shared
    private weak var photosManager = PhotoManager.shared
    
    var fetchResults : PHFetchResult<PHAsset>?
    private var disposeBag = DisposeBag()
    let delegate : MapViewDelegate = MapViewDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("mapview did load")
        mapView.delegate = delegate
        pathManager?.currentPathObservable?.subscribe(onNext: { [unowned self] path in            
            DispatchQueue.main.async {
                log.debug("mapview current path driver - on next")
                self.mapView.load(path: path)
            }
        }).disposed(by: disposeBag)
        
        photosManager?.currentStatusAndAlbum?.drive(onNext: { [weak self] (authStatus,assetCollection) in
                log.debug("mapview current album observer - on next")
                
                if authStatus == .authorized {
                    if assetCollection == nil {
                        self?.fetchResults = nil
                    } else{
                        self?.fetchResults = PHAsset.fetchAssets(in: assetCollection!, options: nil)
                    }
                } else{
                    self?.photosManager?.requestPermission()
            }
        }).disposed(by: disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        log.debug("mapview will appear")
        photosManager?.requestPermission()
    }
    override func viewWillDisappear(_ animated: Bool) {
        log.debug("mapview will disappear")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        log.debug("mapview received memory warning")
    }    
    public var isUserInteractionEnabled : Bool {
        set {
            mapView.isUserInteractionEnabled = newValue
        }
        get {
            return mapView.isUserInteractionEnabled
        }
    }
}

