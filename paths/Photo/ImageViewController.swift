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
 Manages fetching and caching of images for ImageViewControllers.
 */
public class PhotoHelper {
    public let requestOptions = PHImageRequestOptions()
    public var imageManager : PHCachingImageManager?
    public var assetSize : CGSize {
        set{
            if(newValue != _assetSize){
                log.info("change asset size \(newValue)")
                updateItemSize(newValue)
            }
        }
        get {
            return _assetSize
        }
    }
    private var _assetSize = CGSize()
    private var photoManager = PhotoManager.shared
    
    public class var shared : PhotoHelper {
        if _shared == nil {
            _shared = PhotoHelper()
        }
        
        return _shared!
    }
    private static var _shared : PhotoHelper?
    
    private init() {
        imageManager = PHCachingImageManager()
        imageManager?.allowsCachingHighQualityImages = true
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .opportunistic
    }
    
    public var isAuthorized : Bool {
        return photoManager.isAuthorized
    }
    public func startCaching(_ fetched: PHFetchResult<PHAsset>){
        //  let fetched = PHAsset.fetchAssets(in: collection, options: nil)
        guard fetched.count > 0 else{ return }
        imageManager?.stopCachingImagesForAllAssets()
        imageManager?.startCachingImages(for: fetched.objects(at: IndexSet(0...fetched.count-1)), targetSize: self.assetSize, contentMode: .aspectFit, options: requestOptions)
    }
    public func requestImage(for asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID? {
        return imageManager?.requestImage(for: asset, targetSize: assetSize, contentMode: .aspectFit, options: requestOptions, resultHandler: resultHandler)
    }
    public func cancelRequest(_ id: PHImageRequestID?){
        if id != nil {
            imageManager?.cancelImageRequest(id!)
        }
    }
    
    private func updateItemSize(_ itemSize : CGSize) {
        let scale = UIScreen.main.scale
        _assetSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
}

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
