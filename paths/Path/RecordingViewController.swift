//
//  RecordingViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/2/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

/**
 Initializes location updates and presents options for saving the recorded data to a Path.
 */
public class RecordingViewController : BaseRecordingController {
    public static let storyboardID = "recording"
    private static let timeFormatter : DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    var startTime : Date?
    var stopTime : Date?
    
    public var recordingAccuracy : LocationAccuracy = LocationAccuracy.walking
    
    private var timePast : TimeInterval = 0.0
    var timer : Timer?
    lazy var loadingActivityAlert : UIAlertController = {
        let pending = UIAlertController(title: "Creating New Path", message: nil, preferredStyle: .alert)
        
        let indicator =  UIActivityIndicatorView(frame: pending.view.bounds)
        indicator.translatesAutoresizingMaskIntoConstraints = true
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        pending.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
        indicator.startAnimating()
        
        return pending
    }()
    lazy var saveAlert : UIAlertController = {
        let alert = UIAlertController(title: "Save?", message: "What would you like to do with your Path?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default) {[unowned self] _ in self.buttonSaveClicked()}
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.destructive) {[unowned self] _ in self.buttonResetClicked()}
        let actionCancel = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.default) {[unowned self] _ in self.buttonCancelClicked()}
        alert.addAction(actionSave)
        alert.addAction(actionReset)
        alert.addAction(actionCancel)
        
        return alert
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        btnStop.addTarget(self, action: #selector(buttonStopClicked), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblTime.text = "0s"
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (_) in
            self?.timePast += 1
            self?.updateTimer()
        })
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTimer()
        startUpdating(accuracy: recordingAccuracy)
    }
    public override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    private func updateTimer(){
        lblTime.text = RecordingViewController.timeFormatter.string(from: self.timePast)
    }
    
    @objc
    func buttonStopClicked() {
        log.debug("show save alert")
        self.present(saveAlert, animated: true, completion: nil)
    }
    func buttonCancelClicked() {
        log.debug("dismiss save alert")
        self.dismiss(animated: true, completion: nil)
    }
    func buttonSaveClicked() {
        log.debug("saving path")
        stopUpdating()
        timer?.invalidate()
        self.present(loadingActivityAlert, animated: true, completion: nil)
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.save(callback: self.onSaveComplete)
        }
    }
    
    //MARK:- PathManager, LocationManager interaction
    func buttonResetClicked() {
        stopUpdating()
        timer?.invalidate()
        self.navigationController?.popViewController(animated: true)
    }
//
//    public func reset() {
//        [pathManager]?.clearPoints()
//    }
    
    func startUpdating(accuracy: LocationAccuracy) {
        pointsManager.clearPoints()
        
        locationManager?.startLocationUpdates(with: accuracy)
        
        startTime = Date()
        stopTime = nil
    }
    
    public func stopUpdating() {
        stopTime = Date()
        locationManager?.stopLocationUpdates()
    }
    func save(callback: @escaping (Path?,Error?) -> Void) {
        guard let startTime = startTime, let stopTime = stopTime else {
            callback(nil, LocalError.failed(message: "start or stop times were not set"))
            return
        }
        
        let path = pathManager?.getNewPath()
        path?.startdate = startTime
        path?.enddate = stopTime
        pathManager?.save(path: path, callback: callback)
    }
    func onSaveComplete(path: Path?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: false) { //hide spinner
                if error == nil, path != nil {
                    self?.pathManager?.hasNewPath = true
                    
                    var newvcs : [UIViewController] = []
                    if let first = self?.navigationController?.viewControllers.first {
                        newvcs.append(first)
                    }
                    newvcs.append(EditPathViewController())
                    
                    self?.navigationController?.setViewControllers(newvcs, animated: true)
                } else {
                    log.error(error?.localizedDescription ?? "no error message")
                }
            }
        }
    }
}
