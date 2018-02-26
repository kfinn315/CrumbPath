//
//  AllMapViewController.swift
//  paths
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AllMapViewController : UIViewController, MKMapViewDelegate {
    static let storyboardIdentifier : String = "All Paths"
    
    @IBOutlet weak var mapView: MKMapView!
    
    public var overlays : [MKOverlay] = []
    public var boundingRect : MKMapRect? = nil
    override func viewDidLoad() {
        
        let paths = PathManager.shared.getPathsToOverlay()

        for var path in paths! {
            let coords = path.getSimplifiedCoordinates()
            let polyline = MKPolyline(coordinates: coords, count: coords.count)
            if boundingRect == nil {
                boundingRect = polyline.boundingMapRect
            } else {
                boundingRect = MKMapRectUnion(boundingRect!, polyline.boundingMapRect)
            }
            overlays.append(polyline)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        
        mapView.addOverlays(overlays)
      
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
        
        mapView.removeOverlays(overlays)
        mapView.delegate = nil
    }
 
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = MapViewController.strokeColor
        renderer.lineWidth = MapViewController.lineWidth
        
        return renderer
    }
}
