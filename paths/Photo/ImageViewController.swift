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
    
    private lazy var emptyLabel : UILabel = {
        let label = UILabel(frame: CGRect(x:0, y:0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text          = "Click to Add Photos"
        label.font          = label.font.withSize(20)
        label.textColor     = UIColor.white
        return label
    }()
    
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
                if let result = result {
                    self.imageView.image = result.crop(to: self.view.frame.size)
                } else{
                    self.imageView.image = nil
                }
            })
        } else{
            self.imageView.image = nil
        }
        self.imageView.setNeedsDisplay()
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
    public func showEmptyMessage(){
        if !self.view.subviews.contains(self.emptyLabel) {
            self.view.addSubview(self.emptyLabel)
        }
    }
    public func hideEmptyMessage(){
        if let index = self.view.subviews.index(of: self.emptyLabel) {
            self.emptyLabel.removeFromSuperview()
        }
    }
}
