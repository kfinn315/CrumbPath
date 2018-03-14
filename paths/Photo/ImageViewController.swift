//
//  ImageViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/5/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Photos


/**
 Presents a full-screen UIImageView with image of the 'asset' property
 */
public class ImageViewController : UIViewController {
    public static let storyboardID = "ImageView"
    
    public let photoHelper = PhotoHelper.shared
    public var assetIndex : Int?
    public weak var asset : PHAsset?
    private var requestID : PHImageRequestID?
    
    @IBOutlet weak var imageView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log.info("imageView w/ index \(assetIndex ?? -1) disappeared")
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        log.info("imageView w/ index \(assetIndex ?? -1) appeared")
        updateUI()
    }
    public func updateUI(){
        if photoHelper.isAuthorized, let asset = asset {
            self.requestID = photoHelper.requestImage(for: asset, resultHandler: { (result, data) in
                if let result = result {//}, self?.requestID == data?[PHImageResultRequestIDKey] as? PHImageRequestID {
                    
                    self.imageView.image = result.crop(to: self.view.frame.size)
                } else{
                    self.imageView.image = nil
                }
                self.imageView.setNeedsDisplay()
            })
        }
    }
    public func setAsset(asset : PHAsset?, assetIndex : Int){
        log.info("set assetIndex \(assetIndex)")
        
        self.asset = asset
        self.assetIndex = assetIndex
        
        updateUI()
    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        photoHelper.assetSize = view.frame.size
    }
}
