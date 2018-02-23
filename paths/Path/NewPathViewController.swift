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

public class NewPathViewController : BaseRecordingController {
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var segAction: UISegmentedControl!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnStart.addTarget(self, action: #selector(showRecordingView), for: .touchUpInside )
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager?.authorized.drive(onNext: { [unowned self] isAuthorized in
            if isAuthorized {
                self.lblInstructions.text = "Your path accuracy will be set based on the activity type you select."
                self.btnStart.isEnabled = true
            } else {
                //not authorized, show message. prevent recording
                self.lblInstructions.text = "Please enable location in settings"
                self.btnStart.isEnabled = false
            }
        }).disposed(by: disposeBag)
    }
    
    @objc func showRecordingView(){
        if let vc = storyboard?.instantiateViewController(withIdentifier:  RecordingViewController.storyboardID) as? RecordingViewController {
            let accuracy = LocationAccuracy(rawValue: segAction.selectedSegmentIndex) ?? LocationAccuracy.walking
            vc.recordingAccuracy = accuracy
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
