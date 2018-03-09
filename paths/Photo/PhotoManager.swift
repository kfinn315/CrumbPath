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
/**
 Manages the current path's photo album and Photo permission
 */
class PhotoManager {
    private static var _shared : PhotoManager?
    
    //public var currentAlbumId : String?
    public var currentAlbum : Observable<PHAssetCollection?>?
    public var permissionStatus : Driver<PHAuthorizationStatus>?
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
        currentAlbum = currentAlbumSubject.asObservable().observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))//(onErrorJustReturn: nil)
        permissionStatusSubject = BehaviorSubject<PHAuthorizationStatus>(value: PHPhotoLibrary.authorizationStatus())
        
        //when currentPathDriver sends a 'path', get image collection of 'path' and send it to subscribers of currentAlbumDriver
        self.pathManager?.currentPathObservable?.subscribe(onNext: { [weak self] path in
            //let collection = self?.getImageCollection(path?.albumId)
            guard let localid = path?.localid else {return}
            PhotosHelper.getAlbum(named: localid, completion: { (collection) in
                self?.currentAlbumSubject.onNext(collection) //drive photoCollection for current path
            })
        }).disposed(by: self.disposeBag)
        
        permissionStatus = self.permissionStatusSubject.asDriver(onErrorJustReturn: PHAuthorizationStatus.denied)
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
    
    public func addToCurrent(_ assets: [PHAsset], completion: ((Bool, Error?) -> ())?){
        PhotosHelper.getAlbum(named: (pathManager?.currentPath?.localid)!){ [weak self]
            (album) in
            
            if album == nil {
                PhotosHelper.createAlbum(named: (self?.pathManager?.currentPath?.localid)!) {assetCollection in
                    if assetCollection != nil {
                        PhotosHelper.save(assets: assets, to: assetCollection!) {
                            (success, error) in
                            self?.updateCurrentAlbum(collectionid: assetCollection!.localIdentifier)
                            
                            completion?(success,error)
                        }
                    }
                    else{
                        completion?(false, nil) //create error
                    }
                }
            } else{
                PhotosHelper.removeAll(from: album!, completion: { (success, error) in
                    PhotosHelper.save(assets: assets, to: album!) {
                        (success, error) in
                        self?.currentAlbumSubject.onNext(album)
                        completion?(success,error)
                    }
                })
            }
            
        }
    }
}

extension PHImageManager {
    func requestImageThumbnail(for phasset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable:Any]?) -> Void) {
        self.requestImage(for: phasset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil, resultHandler: resultHandler)
    }
}
