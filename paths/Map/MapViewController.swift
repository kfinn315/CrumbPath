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

class MapViewController: UIViewController {
    public static let storyboardID = "MapVC"
    
    @IBOutlet weak var mapView: MapView!
    
    private weak var pathManager = PathManager.shared
    private weak var photosManager = PhotoManager.shared
    
    //fileprivate var imageManager : PHCachingImageManager?
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
                self.mapView.loadPath(path: path)
            }
        }).disposed(by: disposeBag)
        photosManager?.currentAlbum?.subscribe(onNext: {[weak self] collection in
            log.debug("mapview current album observer - on next")
            if collection == nil {
                self?.fetchResults = nil
            } else{
                self?.fetchResults = PHAsset.fetchAssets(in: collection!, options: nil)
            }
            self?.reloadImageAnnotations()
        }).disposed(by: disposeBag)
        
        photosManager?.permissionStatus?.drive(onNext: { [weak self] auth in
            if self?.photosManager?.isAuthorized ?? false {
                //self?.imageManager = PHCachingImageManager()
                self?.reloadImageAnnotations()
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
    func reloadImageAnnotations() {
        log.debug("IMG reload")
        
        if fetchResults != nil {
            var imageAnnotations : [ImageAnnotation] = []
            
            fetchResults!.enumerateObjects({ (asset, startindex, end) in
                if let loc = asset.location {
                    let annotation = ImageAnnotation()
                    annotation.coordinate = loc.coordinate
                    annotation.asset = asset
                    annotation.title = "!"
                    imageAnnotations.append(annotation)
                }
            })
            
            mapView.setPathAnnotations(imageAnnotations)
        }
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

