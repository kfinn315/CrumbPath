//
//  PhotoManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/19/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

protocol PhotoManagerInterface {
    func getImageCollection(_ localid: String?) -> PHAssetCollection?
    var photoCollections : [PhotoCollection] {get}
}

class PhotoManager {
    private static var _shared : PhotoManager?

    public var currentAlbumId : String?
    public var currentAlbumDriver : Driver<PHAssetCollection?>?
    public var permissionStatusDriver : Driver<PHAuthorizationStatus>?
    public var authorizationStatus = PHPhotoLibrary.authorizationStatus()
    public var isAuthorized : Bool {
        return authorizationStatus == .authorized || authorizationStatus == .restricted
    }
    
    private weak var pathManager = PathManager.shared
    private var fetchOptions = PHFetchOptions()
    private let currentAlbumSubject : BehaviorSubject<PHAssetCollection?>
    private var permissionStatusSubject : BehaviorSubject<PHAuthorizationStatus>
    private var disposeBag = DisposeBag()

    public static var shared : PhotoManager {
        if _shared == nil {
            _shared = PhotoManager()
        }
        
        return _shared!
    }
    
    private init(){
        currentAlbumSubject = BehaviorSubject<PHAssetCollection?>(value: nil)
        currentAlbumDriver = currentAlbumSubject.asDriver(onErrorJustReturn: nil)
        permissionStatusSubject = BehaviorSubject<PHAuthorizationStatus>(value: PHPhotoLibrary.authorizationStatus())
        
        //when currentPathDriver sends a 'path', get image collection of 'path' and send it to subscribers of currentAlbumDriver
        DispatchQueue.main.async {
            self.pathManager?.currentPathDriver?.drive(onNext: { [weak self] path in
                DispatchQueue.global(qos: .userInitiated).async {
                    let collection = self?.getImageCollection(path?.albumId)
                    self?.currentAlbumSubject.onNext(collection) //drive photoCollection for current path
                }
            }).disposed(by: self.disposeBag)
        }
        
        permissionStatusDriver = self.permissionStatusSubject.asDriver(onErrorJustReturn: PHAuthorizationStatus.denied)
    }
    
    public func updateCurrentAlbum(collectionid: String) {
        pathManager?.updateCurrentAlbum(collectionid: collectionid) //will not notify
        currentAlbumSubject.onNext(getImageCollection(collectionid)) //will notify
    }
    
    public func requestPermission(){
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({[weak self] (status) in
                if status != .notDetermined {
                    self?.permissionStatusSubject.onNext(status)
                }
            })
        }
    }
    public func getImageCollection(_ localid: String?) -> PHAssetCollection? {
        guard isAuthorized, localid != nil else{
            return nil
        }
        
        var photocollection : PhotoCollection?
        
        if let coll = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localid!], options: nil).firstObject {
            photocollection = PhotoCollection(coll)
        }
        
        return photocollection?.collection ?? nil
    }
    
    public func fetchAssets(in collection: PHAssetCollection, options: PHFetchOptions?) ->
        PHFetchResult<PHAsset>{
            
            guard self.isAuthorized else{
                return PHFetchResult<PHAsset>()
            }
            
            return PHAsset.fetchAssets(in: collection, options: options)
    }
    public lazy var photoCollections : [PhotoCollection] = {
        var data : [PhotoCollection] = []
        
        guard self.isAuthorized else{
            return []
        }
        
        let topLevelfetchOptions = PHFetchOptions()
        
        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: topLevelfetchOptions)
        
        topLevelUserCollections.enumerateObjects({ (asset, _, _) in
            if let a = asset as? PHAssetCollection, a.estimatedAssetCount > 0 {
                let obj = PhotoCollection(a)
                data.append(obj)
            }
        })
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
        
        smartAlbums.enumerateObjects({ (asset, _, _) in
            let a = asset as PHAssetCollection
            if a.estimatedAssetCount > 0 {
                let obj = PhotoCollection(a)
                data.append(obj)
            }
        })
        
        data.sort(by: { (date0, date1) -> Bool in
            return date0.collection.endDate ?? Date() <= date1.collection.endDate ?? Date()
        })
        return data
    }()
}

extension PHImageManager {
    func requestImageThumbnail(for phasset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable:Any]?) -> Void) {
        self.requestImage(for: phasset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil, resultHandler: resultHandler)
    }
}
