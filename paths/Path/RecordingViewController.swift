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

public class RecordingViewController : BaseRecordingController {
    public static let storyboardID = "recording"
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    public var recordingAccuracy : LocationAccuracy = LocationAccuracy.walking
    
    private var timePast : TimeInterval = 0.0
    var timer : Timer?
    private let timeFormatter : DateComponentsFormatter
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
        let alert = UIAlertController(title: "Save?", message: "Would you like to save this path or reset?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default) {[unowned self] _ in self.buttonSaveClicked()}
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.default) {[unowned self] _ in self.buttonResetClicked()}
        alert.addAction(actionSave)
        alert.addAction(actionReset)
        
        return alert
    }()
    
    required public init?(coder aDecoder: NSCoder) {
        timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.hour, .minute, .second]
        timeFormatter.unitsStyle = .abbreviated
        
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        btnStop.addTarget(self, action: #selector(buttonStopClicked), for: .touchUpInside)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (_) in
            self?.timePast += 1
            self?.updateView()
        })
//
//        if !isRecording {
//            startUpdating(accuracy: recordingAccuracy)
//            isRecording = true
//        } else{
//            log.error("recording vc is already recording")
//        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    @objc
    func buttonStopClicked() {
        stopUpdating()
        timer?.invalidate()
        log.debug("show save alert")
        self.present(saveAlert, animated: true, completion: nil)
    }
    
    private func updateView(){
        lblTime.text = timeFormatter.string(from: self.timePast)
    }
    
    func buttonSaveClicked() {
        //show spinner
        self.present(loadingActivityAlert, animated: true, completion: nil)
        
        log.debug("saving path")
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            self.save(callback: self.onSaveComplete)
        }
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
    
    //MARK:- PathManager, LocationManager interaction
    func buttonResetClicked() {
        //go to new path vc
        self.navigationController?.popViewController(animated: true)
    }
    
    public func save(callback: @escaping (Path?,Error?) -> Void) {
        pathManager?.savePath(start: startTime ?? Date(), end: stopTime ?? Date(), callback: callback)
    }
    
    public func reset() {
        pathManager?.clearPoints()
    }
    
    func startUpdating(accuracy: LocationAccuracy) {
        pathManager?.clearPoints()
        
        locationManager?.startLocationUpdates(with: accuracy)
        
        startTime = Date()
        stopTime = nil
    }
    
    public func stopUpdating() {
        stopTime = Date()
        locationManager?.stopLocationUpdates()
    }
}
