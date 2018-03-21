//
//  MapViewDelegate.swift
//  paths
//
//  Created by Kevin Finn on 3/9/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import MapKit
import UIKit
import RxSwift
import RxCocoa
import Photos

/**
 Defines how a MKMapView should display annotations and overlays
 */
class MapViewDelegate : NSObject, MKMapViewDelegate {
    static let lineTolerance : Float = 0.000005
    static let annotationLatDelta : CLLocationDistance = 0.010
    static let strokeColor = UIColor.red
    static let lineWidth = CGFloat(2.0)
    static let pinAnnotationImageView = UIImage.circle(diameter: CGFloat(10), color: UIColor.orange)
    static let thumbnailSize = CGSize(width: 50, height: 50)
    private weak var photosManager = PhotoManager.shared
    
    // MARK: - MapViewDelegate implementation
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = MapViewDelegate.strokeColor
        renderer.lineWidth = MapViewDelegate.lineWidth
        
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
                annotationView!.assetId = photosManager?.cachingImageManager?.requestImage(for: imgAsset, targetSize: MapViewDelegate.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {
                    image, data in
                    if annotationView!.assetId == data?[PHImageResultRequestIDKey] as? Int32 {
                        annotationView!.image = image
                    }
                })
            }
            return annotationView
        } else if annotation is PathAnnotation {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pathAnnotation")
            
            if view == nil {
                view = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "pathAnnotation")
            } else {
                view!.annotation = annotation
            }
            
            view!.image = MapViewDelegate.pinAnnotationImageView
            view!.canShowCallout = true
            let label = UILabel()
            label.text = "\(annotation.title): \(annotation.subtitle)"
            view!.rightCalloutAccessoryView = label
            return view
        } else{ //mkpointAnnotation
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "normalAnnotation")
            
            if view == nil {
                  view = MKAnnotationView.init(annotation: annotation, reuseIdentifier: "normalAnnotation")
            } else {
                view!.annotation = annotation
            }
            
            view!.image = MapViewDelegate.pinAnnotationImageView
            return view
        }
    }
}
