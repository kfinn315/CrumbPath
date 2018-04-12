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
    
    @IBOutlet weak var btnAction: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        doneButton.action = #selector(closeModal)
        btnAction.action = #selector(doAction)
    }
    
    @objc func closeModal(){
        dismiss(animated: true, completion: nil)
    }
    @objc func doAction(){
        var actionsheet = UIAlertController(title: "Export", message: "", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "View in Google Maps", style: .default, handler: { action in
            guard let url = URL(string: "http://maps.googleapis.com/maps/api/staticmap?size=400x400&path=40.737102,-73.990318|40.749825,-73.987963|40.752946,-73.987384|40.755823,-73.986397&sensor=false") else{ return }
            UIApplication.shared.openURL(url);//getMapsURLforLine(mapV)!)
            //            http://maps.googleapis.com/maps/api/staticmap?size=400x400&path=40.737102,-73.990318|40.749825,-73.987963|40.752946,-73.987384|40.755823,-73.986397&sensor=false
            //
            //        }))
            
        }))
        present(actionsheet, animated: true, completion: nil)
    }
    func setMapView(_ mapview : MapView){
        //        if childViewControllers.count > 0, let mapViewController = childViewControllers[0] as? MapViewController {
        //            mapViewController.mapView = mapview
        //        }
    }
}

