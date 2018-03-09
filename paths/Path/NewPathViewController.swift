//
//  NewPathViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/11/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData
import CloudKit
import RxCocoa
import RxSwift

/**
 Starting point to record a new Path
 */
public class NewPathViewController : BaseRecordingController {
    public static let storyboardID = "New Path"
    @IBOutlet weak var stackvwContent: UIStackView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var segAction: UISegmentedControl!
    @IBOutlet weak var stackvwEnableLocation: UIStackView!
    @IBOutlet weak var btnLocationSettings: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        btnLocationSettings.addTarget(self, action: #selector(openLocationSettings), for: .touchUpInside)
        btnStart.addTarget(self, action: #selector(showRecordingView), for: .touchUpInside )
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager?.authorized.drive(onNext: { [unowned self] isAuthorized in
            if isAuthorized {
                self.enableRecording()
            } else {
                self.disableRecording()
            }
        }).disposed(by: disposeBag)
        
    }
    func enableRecording(){
        self.btnStart.isEnabled = true
        let subviews =  stackvwContent.arrangedSubviews
        
        subviews.forEach {
            if $0.tag == -1 {
                $0.isHidden = true
            } else{
                $0.isHidden = false
            }
        }
    }
    
    func disableRecording(){
        self.btnStart.isEnabled = false
        let subviews =  stackvwContent.arrangedSubviews
        subviews.forEach {
            if $0.tag == -1 {
                $0.isHidden = false
            } else{
                $0.isHidden = true
            }
        }
    }
    @objc func openLocationSettings(){
        if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @objc func showRecordingView(){
        if let vc = storyboard?.instantiateViewController(withIdentifier:  RecordingViewController.storyboardID) as? RecordingViewController {
            let accuracy = LocationAccuracy(rawValue: segAction.selectedSegmentIndex) ?? LocationAccuracy.walking
            vc.recordingAccuracy = accuracy
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
