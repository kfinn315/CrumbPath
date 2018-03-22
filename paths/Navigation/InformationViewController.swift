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
import MessageUI

class InformationViewController : UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var labelPhotosPermission: UILabel!
    @IBOutlet weak var labelMotionPermission: UILabel!
    @IBOutlet weak var labelLocationPermission: UILabel!
    
    @IBOutlet weak var cellLibraries: UITableViewCell!
    @IBOutlet weak var cellGitHub: UITableViewCell!
    @IBOutlet weak var cellEmail: UITableViewCell!
    static let storyboardID = "Information"
    
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
        
        if cell == cellLibraries {
            showThirdPartyLicenses()
        } else if cell == cellEmail {
            sendEmail()
        } else if cell == cellGitHub {
            launchGitHub()
        }
    }
    @objc func sendEmail(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["kfinn315@gmail.com"])
            mail.setSubject("About your app!")
            present(mail, animated: true)
        } else {
            // show failure alert
            log.error("unable to compose mail message")
        }
    }
    @objc func launchGitHub(){
        if let url = URL(string: "https://www.github.com/kfinn315/") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                _ = UIApplication.shared.openURL(url)
            }
        }
    }
    
    func showThirdPartyLicenses(){
        self.navigationController?.pushViewController(licensesViewController, animated: true)
    }
    
    //MARK:- MFMailComposeViewControllerDelegate implementation
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        dismiss(animated: true, completion: nil)
        
        if let error = error {
            log.error(error.localizedDescription)
        }
    }
    
}
