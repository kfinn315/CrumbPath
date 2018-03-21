//
//  PhotoHelper.swift
//  paths
//
//  Created by Kevin Finn on 3/14/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Photos

/**
 Manages fetching and caching of images for ImageViewController.
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
        imageManager = photoManager.cachingImageManager
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .opportunistic
    }
    
    public var isAuthorized : Bool {
        return photoManager.isAuthorized
    }
    public func startCaching(_ fetched: PHFetchResult<PHAsset>){
        guard isAuthorized else{ return }
        
        guard fetched.count > 0 else{ return }
        imageManager?.stopCachingImagesForAllAssets()
        imageManager?.startCachingImages(for: fetched.objects(at: IndexSet(0...fetched.count-1)), targetSize: self.assetSize, contentMode: .aspectFit, options: requestOptions)
    }
    public func requestImage(for asset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> PHImageRequestID? {
        guard isAuthorized else{ return nil }
        
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
