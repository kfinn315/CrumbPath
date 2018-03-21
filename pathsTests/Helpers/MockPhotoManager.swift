//
//  MockPhotoManager.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/20/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import RxSwift
import RxCocoa
import Photos

@testable import paths

class MockPhotoManager : IPhotoManager {
    var invokedCurrentAlbumGetter = false
    var invokedCurrentAlbumGetterCount = 0
    var stubbedCurrentAlbum: Observable<PHAssetCollection?>!
    var currentAlbum : Observable<PHAssetCollection?>? {
        invokedCurrentAlbumGetter = true
        invokedCurrentAlbumGetterCount += 1
        return stubbedCurrentAlbum
    }
    var invokedPermissionStatusGetter = false
    var invokedPermissionStatusGetterCount = 0
    var stubbedPermissionStatus: Driver<PHAuthorizationStatus>!
    var permissionStatus : Driver<PHAuthorizationStatus>? {
        invokedPermissionStatusGetter = true
        invokedPermissionStatusGetterCount += 1
        return stubbedPermissionStatus
    }
    var invokedIsAuthorizedGetter = false
    var invokedIsAuthorizedGetterCount = 0
    var stubbedIsAuthorized: Bool! = false
    var isAuthorized : Bool {
        invokedIsAuthorizedGetter = true
        invokedIsAuthorizedGetterCount += 1
        return stubbedIsAuthorized
    }
    var invokedPhotoCollectionsGetter = false
    var invokedPhotoCollectionsGetterCount = 0
    var stubbedPhotoCollections: [PhotoCollection]! = []
    var photoCollections : [PhotoCollection] {
        invokedPhotoCollectionsGetter = true
        invokedPhotoCollectionsGetterCount += 1
        return stubbedPhotoCollections
    }
    var invokedAuthorizationStatusGetter = false
    var invokedAuthorizationStatusGetterCount = 0
    var stubbedAuthorizationStatus: PHAuthorizationStatus!
    var authorizationStatus : PHAuthorizationStatus {
        invokedAuthorizationStatusGetter = true
        invokedAuthorizationStatusGetterCount += 1
        return stubbedAuthorizationStatus
    }
    var invokedUpdateCurrentAlbum = false
    var invokedUpdateCurrentAlbumCount = 0
    var invokedUpdateCurrentAlbumParameters: (collectionid: String, Void)?
    var invokedUpdateCurrentAlbumParametersList = [(collectionid: String, Void)]()
    func updateCurrentAlbum(collectionid : String) {
        invokedUpdateCurrentAlbum = true
        invokedUpdateCurrentAlbumCount += 1
        invokedUpdateCurrentAlbumParameters = (collectionid, ())
        invokedUpdateCurrentAlbumParametersList.append((collectionid, ()))
    }
    var invokedRequestPermission = false
    var invokedRequestPermissionCount = 0
    func requestPermission() {
        invokedRequestPermission = true
        invokedRequestPermissionCount += 1
    }
    var invokedGetImageCollection = false
    var invokedGetImageCollectionCount = 0
    var invokedGetImageCollectionParameters: (localid: String?, Void)?
    var invokedGetImageCollectionParametersList = [(localid: String?, Void)]()
    var stubbedGetImageCollectionResult: PHAssetCollection!
    func getImageCollection(_ localid: String?) -> PHAssetCollection? {
        invokedGetImageCollection = true
        invokedGetImageCollectionCount += 1
        invokedGetImageCollectionParameters = (localid, ())
        invokedGetImageCollectionParametersList.append((localid, ()))
        return stubbedGetImageCollectionResult
    }
    var invokedFetchAssets = false
    var invokedFetchAssetsCount = 0
    var invokedFetchAssetsParameters: (collection: PHAssetCollection, options: PHFetchOptions?)?
    var invokedFetchAssetsParametersList = [(collection: PHAssetCollection, options: PHFetchOptions?)]()
    var stubbedFetchAssetsResult: PHFetchResult<PHAsset>!
    func fetchAssets(in collection: PHAssetCollection, options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        invokedFetchAssets = true
        invokedFetchAssetsCount += 1
        invokedFetchAssetsParameters = (collection, options)
        invokedFetchAssetsParametersList.append((collection, options))
        return stubbedFetchAssetsResult
    }
    var invokedAddToCurrent = false
    var invokedAddToCurrentCount = 0
    var invokedAddToCurrentParameters: (assets: [PHAsset], Void)?
    var invokedAddToCurrentParametersList = [(assets: [PHAsset], Void)]()
    var stubbedAddToCurrentCompletionResult: (Bool, Error?)?
    func addToCurrent(_ assets: [PHAsset], completion: ((Bool, Error?) -> ())?) {
        invokedAddToCurrent = true
        invokedAddToCurrentCount += 1
        invokedAddToCurrentParameters = (assets, ())
        invokedAddToCurrentParametersList.append((assets, ()))
        if let result = stubbedAddToCurrentCompletionResult {
            completion?(result.0, result.1)
        }
    }
}
