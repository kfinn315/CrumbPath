//
//  SettingsViewController.swift
//  paths
//
//  Created by Kevin Finn on 3/14/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import Foundation
import UIKit
import LicensesKit
import CoreMotion

class InformationViewController : UITableViewController {
    
    @IBOutlet weak var labelPhotosPermission: UILabel!
    @IBOutlet weak var labelMotionPermission: UILabel!
    @IBOutlet weak var labelLocationPermission: UILabel!
    
    lazy var licensesViewController : LicensesViewController = {
        let licensesVC = LicensesViewController()
        
        if let urlpath = Bundle.main.path(forResource: "licenses", ofType: "json") {
            licensesVC.setNoticesFromJSONFile(filepath: urlpath)
        }
        
        return licensesVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        
        labelPhotosPermission.text = getPhotoPermission()
        labelLocationPermission.text = getLocationPermission()
        
        if #available(iOS 11.0, *) {
            labelMotionPermission.text = getMotionPermission()
        } else {
            // Fallback on earlier versions
            labelMotionPermission.text = "N/A"
        }
    }
    
    func getPhotoPermission() -> String {
        let photoStatus = PhotoManager.shared.authorizationStatus
        var status : String!
        
        switch photoStatus {
        case .authorized:
            status = "Authorized"
            break
        case .denied:
            status = "Denied"
            break
        case .restricted:
            status = "Restricted"
        case .notDetermined:
            status = "Not set"
        }
        
        return status
    }
    
    func getLocationPermission() -> String {
        let locationStatus = LocationManager.authorizationStatus
        var status : String!
        
        switch locationStatus {
        case .denied:
            status = "Denied"
            break
        case .restricted:
            status = "Restricted"
        case .notDetermined:
            status = "Not set"
        case .authorizedWhenInUse:
            status = "When in use"
        case .authorizedAlways:
            status = "Authorized always"
        }
        
        return status
    }
    
    @available(iOS 11.0, *)
    func getMotionPermission() -> String {
        let motionStatus = CMMotionActivityManager.authorizationStatus()
        var status : String!
        
        switch motionStatus {
        case .denied:
            status = "Denied"
            break
        case .restricted:
            status = "Restricted"
        case .notDetermined:
            status = "Not set"
        case .authorized:
            status = "Authorized"
        }
        
        return status
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        
        switch cell.tag {
        case 3:
            showThirdPartyLicenses()
            break
        default:
            break
        }
    }
    
    func showThirdPartyLicenses(){
        self.navigationController?.pushViewController(licensesViewController, animated: true)
    }
}
