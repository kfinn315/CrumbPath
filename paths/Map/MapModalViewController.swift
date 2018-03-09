//
//  MapModalViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit

/**
 View that wraps a MapViewController to display in a modal
 */
class MapModalViewController: UIViewController {
    public static let storyboardID = "MapModal"
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
 
    override func viewDidLoad() {
        doneButton.action = #selector(closeModal)
    }
    
    @objc func closeModal(){
        dismiss(animated: true, completion: nil)
    }
    
    func setMapView(_ mapview : MapView){
//        if childViewControllers.count > 0, let mapViewController = childViewControllers[0] as? MapViewController {
//            mapViewController.mapView = mapview
//        }
    }
}

