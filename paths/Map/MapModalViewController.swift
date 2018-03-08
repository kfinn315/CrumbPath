//
//  MapViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit

class MapModalViewController: UIViewController {
    public static let storyboardID = "MapModal"
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    private lazy var contentViewController : UIViewController = {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: MapViewController.storyboardID) as! MapViewController
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        doneButton.action = #selector(closeModal)
    }
    
    @objc func closeModal(){
        dismiss(animated: true, completion: nil)
    }
    
    private func updateView() {
        add(asChildViewController: contentViewController)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
       
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    
    
}

