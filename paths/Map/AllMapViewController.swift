//
//  AllMapViewController.swift
//  paths
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import RxCoreData
import RxSwift
import RxCocoa

/**
 ViewController that displays all the Path objects saved in CoreData
 */
class AllMapViewController : UIViewController {
    static let storyboardIdentifier : String = "All Paths"
    
    @IBOutlet weak var mapView: MapView!
    
//    public var overlays : [MKOverlay] = []
    public var boundingRect : MKMapRect? = nil
    private let mapViewDelegate = MapViewDelegate()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        //let paths = PathManager.shared.getAllPaths()

        mapView.delegate = mapViewDelegate
        
        let fetchRequest : NSFetchRequest<Path> = Path.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "title", ascending: false)]
        PathManager.managedObjectContext.rx.entities(fetchRequest: fetchRequest).asObservable().subscribe(onNext: { (paths) in
            
            self.mapView.clear()
            //self.overlays = []
            self.mapView.removeOverlays()
            var overlays : [MKOverlay] = []
            paths.forEach({ (path) in
                let coords = path.getSimplifiedCoordinates()
                let polyline = MKPolyline(coordinates: coords, count: coords.count)
                if self.boundingRect == nil {
                    self.boundingRect = polyline.boundingMapRect
                } else {
                    self.boundingRect = MKMapRectUnion(self.boundingRect!, polyline.boundingMapRect)
                }
                overlays.append(polyline)
            })
            
            self.mapView.addOverlays(overlays)
        }).disposed(by: disposeBag)
    }
    deinit {
        mapView.delegate = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        if let boundingRect = boundingRect {
            let zoomRect = mapView.mapRectThatFits(boundingRect)
            if(!MKMapRectIsEmpty(zoomRect)) {
                mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(5, 5, 5, 5), animated: false)
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.removeOverlays()
        mapView.delegate = nil
    }
 
//    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = MapViewController.strokeColor
//        renderer.lineWidth = MapViewController.lineWidth
//
//        return renderer
//    }
}
