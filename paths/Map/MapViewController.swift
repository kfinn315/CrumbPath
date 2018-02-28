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

class MapViewController: UIViewController, MKMapViewDelegate {
    public static let storyboardID = "MapVC"
    
    @IBOutlet weak var mapView: MKMapView!
    
    static let lineTolerance : Float = 0.000005
    static let annotationLatDelta : CLLocationDistance = 0.010
    static let strokeColor = UIColor.red
    static let lineWidth = CGFloat(2.0)
    static let pinAnnotationImageView = UIImage.circle(diameter: CGFloat(10), color: UIColor.orange)
    static let thumbnailSize = CGSize(width: 50, height: 50)
    
    private var polyline : MKPolyline?
    private var pathAnnotations : [MKPointAnnotation] = []
    private var imageAnnotations : [MKAnnotation] = []
    
    private weak var pathManager = PathManager.shared
    private weak var photosManager = PhotoManager.shared
    
    fileprivate var imageManager : PHCachingImageManager?
    var fetchResults : PHFetchResult<PHAsset>?
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("mapview did load")
        mapView.delegate = self

        pathManager?.currentPathObservable?.subscribeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] path in
                log.debug("mapview current path driver - on next")
                self.loadPath(path: path)
        }).disposed(by: disposeBag)
        
        photosManager?.currentAlbumObservable?.subscribe(onNext: {[unowned self] collection in
            log.debug("mapview current album observer - on next")
            if collection == nil {
                self.fetchResults = nil
            } else{
                self.fetchResults = PHAsset.fetchAssets(in: collection!, options: nil)
            }
            self.reloadImageAnnotations()
        }).disposed(by: disposeBag)
        
        photosManager?.permissionStatusDriver?.drive(onNext: { [unowned self] auth in
            if self.photosManager?.isAuthorized ?? false {
                self.imageManager = PHCachingImageManager()
                self.reloadImageAnnotations()
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

        let group = DispatchGroup()
        DispatchQueue.main.async {
            group.enter()
            self.removeImageAnnotations()
            group.leave()
        }
        
        group.wait()

        imageAnnotations = []
        
        if fetchResults != nil {
            fetchResults!.enumerateObjects({ (asset, startindex, end) in
                if let loc = asset.location {
                    let annotation = ImageAnnotation()
                    annotation.coordinate = loc.coordinate
                    annotation.asset = asset
                    annotation.title = "!"
                    self.imageAnnotations.append(annotation)
                }
            })
        }
        
        DispatchQueue.main.async {
            log.debug("add image annotations to map")
            self.mapView.addAnnotations(self.imageAnnotations)
        }
    }
    
    private func removePathAnnotations(){
        log.debug("PATH remove annotations")
        mapView?.removeAnnotations((mapView?.annotations.filter() {
            !($0 is ImageAnnotation)
            }) ?? [])
    }
    
    private func removeImageAnnotations(){
        log.debug("IMG remove annotations")
        mapView?.removeAnnotations((mapView?.annotations.filter() {
            $0 is ImageAnnotation
            }) ?? [])
    }
    
    private func removeOverlay(){
        log.debug("PATH remove overlays")
        mapView?.removeOverlays((mapView?.overlays)!)
    }
    
    public func loadPath(path: Path?) {
        log.debug("PATH loadPath")
        self.removePathAnnotations()
        self.removeOverlay()
        addPolyline(coordinates: path?.getSimplifiedCoordinates() ?? [])
    }
    
    func addPolyline(coordinates: [CLLocationCoordinate2D]) {
        DispatchQueue.global(qos: .userInitiated).sync {
            log.debug("PATH create polyline from coordinates")
            
            let coordinates = coordinates
            self.polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            
            self.pathAnnotations = []
            
            //add annotation to first and last coords
            if let firstcoord = coordinates.first {
                let firstpin = MKPointAnnotation()
                firstpin.coordinate = firstcoord
                self.pathAnnotations.append(firstpin)
            }
            if coordinates.count > 1, let lastcoord = coordinates.last {
                let lastpin = MKPointAnnotation()
                lastpin.coordinate = lastcoord
                self.pathAnnotations.append(lastpin)
            }
        }
        if let polyline = self.polyline {
            DispatchQueue.main.async {
                log.debug("PATH draw polyline on map")
                self.mapView?.add(polyline)
                self.mapView?.addAnnotations(self.pathAnnotations)
                self.zoomToContent()
            }
        }
    }
    private func zoomToContent(){
        if let polyline = polyline {
            let boundingRect = polyline.boundingMapRect
            mapView.setVisibleMapRect(boundingRect, edgePadding:  UIEdgeInsetsMake(25.0,25.0,25.0,25.0), animated: false)
            if mapView.camera.altitude < 200 {
                mapView.camera.altitude = 1000
            }
        } else{
            zoomToPathAnnotations()
        }
    }
//    func clearMap() {
//        log.debug("mapview clear map")
////        removeAllAnnotations()
//        removeOverlay()
//        removePathAnnotations()
//    }
    
    func zoomToPoint(_ point: CLLocation, animated: Bool) {
        log.debug("mapview zoom to point")
        var zoomRect = MKMapRectNull
        let mappoint = MKMapPointForCoordinate(point.coordinate)
        let pointRect = MKMapRectMake(mappoint.x, mappoint.y, 0.1, 0.1)
        zoomRect = MKMapRectUnion(zoomRect, pointRect)
        mapView?.setVisibleMapRect(zoomRect, animated: true)
    }
    
    func zoomToFit() {
        log.debug("mapview zoom to fit")
        mapView?.setVisibleMapRect(getZoomRect(from: mapView.annotations), animated: true)
    }
    func zoomToPathAnnotations() {
        mapView?.setVisibleMapRect(getZoomRect(from: pathAnnotations), animated: false)
    }
    private func getZoomRect(from annotations: [MKAnnotation]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        return zoomRect
    }
    private func getZoomRect(from coords: [CLLocationCoordinate2D]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        
        for coord in coords {
            let point = MKMapPointForCoordinate(coord)
            let pointRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        return MKMapRectInset(zoomRect, -5.0, -5.0)
    }
    
    // MARK: - MapViewDelegate implementation
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = MapViewController.strokeColor
        renderer.lineWidth = MapViewController.lineWidth
        
        return renderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        log.debug("mapview add annotation")
        
        if annotation is ImageAnnotation, let imgAnnotation = annotation as? ImageAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ImageAnnotationView.reuseIdentifier) as? ImageAnnotationView
            
            if annotationView == nil{
                annotationView = ImageAnnotationView(annotation: imgAnnotation, reuseIdentifier: ImageAnnotationView.reuseIdentifier)
            } else{
                annotationView!.annotation = annotation
            }
            if photosManager?.isAuthorized ?? false, let imgAsset = imgAnnotation.asset {
                annotationView!.assetId = imageManager?.requestImage(for: imgAsset, targetSize: MapViewController.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {
                    image, data in
                    if annotationView!.assetId == data?[PHImageResultRequestIDKey] as? Int32 {
                        annotationView!.image = image
                    }
                })
            }
            return annotationView
        } else {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "normalAnnotation")
            
            if view == nil {
                view = MKAnnotationView.init(annotation: annotation, reuseIdentifier: "normalAnnotation")
            } else {
                view!.annotation = annotation
            }
            
            view!.image = MapViewController.pinAnnotationImageView
            
            return view
        }
    }
    
    public func getSnapshot(from path: Path, _ callback: @escaping MKMapSnapshotCompletionHandler) {
        let options = MKMapSnapshotOptions()
        if #available(iOS 11.0, *) {
            options.mapType = MKMapType.mutedStandard
        } else {
            // Fallback on earlier versions
        }
        
        options.mapRect = getZoomRect(from: path.getPoints())
        options.camera.altitude = 12500
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { (snapshot, error) in
            //draw on img here
            callback(snapshot, error)
        }
    }
    
    //    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    //        if let imgAnnotation = view as? ImageAnnotation {
    //
    //        }
    //    }
}

