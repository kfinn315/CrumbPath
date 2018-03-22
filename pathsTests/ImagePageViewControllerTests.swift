//
//  PhotoManager.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/20/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RxSwift
import RxCocoa
import CoreData
import RandomKit
import Photos

@testable import paths

class ImagePageViewControllerTests : QuickSpec {
    override func spec(){
        var imagePageVC : ImagePageViewController!
        var window : UIWindow!
        var coreData : ContextWrapper!
        var pathManager : PathManager!
        var mockPhotoManager : MockPhotoManager!
        var photoCollectionSubject : BehaviorSubject<PHAssetCollection?>!
        var statusSubject : BehaviorSubject<PHAuthorizationStatus>!
        //var statusDriver : Driver<PHAuthorizationStatus>!
        
        describe("ImageViewController"){
            beforeEach {
                mockPhotoManager = MockPhotoManager()
                
                window = UIWindow(frame: UIScreen.main.bounds)
                
                imagePageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ImagePageViewController.storyboardID) as! ImagePageViewController
                imagePageVC.photoManager = mockPhotoManager
                
                window.set(root: imagePageVC)
                
                coreData = ContextWrapper()
                PathManager.managedObjectContext = coreData.context!
                
                statusSubject = BehaviorSubject<PHAuthorizationStatus>(value: .notDetermined)
                mockPhotoManager.stubbedPermissionStatus = statusSubject.asDriver(onErrorJustReturn: .notDetermined)
                statusSubject.onNext(.authorized)

                photoCollectionSubject = BehaviorSubject<PHAssetCollection?>(value: nil)
                mockPhotoManager.stubbedCurrentAlbum = photoCollectionSubject.asDriver(onErrorJustReturn: nil).asObservable()
                
                mockPhotoManager.stubbedIsAuthorized = true
            }
            
            describe("tapping on a page"){
                beforeEach {
                    
                }
                expect("ImageViewController is displayed as a modal"){
                    
                }
            }
            describe("photo permissions"){
                
                beforeEach {
                    
                    mockPhotoManager.stubbedPermissionStatus = statusSubject.asObserver()
                }
                context("permission status is undetermined"){
                    beforeEach {
                        mockPhotoManager.stubbedIsAuthorized = false
                        statusSubject.onNext(.notDetermined)
                    }
                    it("asks user for permission"){
                        
                    }
                }
                context("permission status is denied"){
                    beforeEach {
                        mockPhotoManager.stubbedIsAuthorized = false
                        statusSubject.onNext(.denied)
                    }
                    it("shows a permission message on page"){
                        
                    }
                }
                context("permission status is given"){
                    beforeEach {
                        statusSubject.onNext(.authorized)
                    }
                    it("operates normally"){
                    }
                }
            }
            describe("asset collection displayed"){
                context("nil album"){
                    beforeEach {
                        photoCollectionSubject.onNext(nil)
                    }
                }
                context("0 photos"){
                    var assetColl : PHAssetCollection!
                    beforeEach {
                        assetColl = PHAssetCollection.transientAssetCollection(with: [], title: "0 photos")
                        photoCollectionSubject.onNext(assetColl)
                    }
                }
                context("1 photo"){
                    var assetColl : PHAssetCollection!
                    beforeEach {
                        var assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                        if assets.count > 0 {
                            assetColl = PHAssetCollection.transientAssetCollection(with: [assets.firstObject!], title: "1 photo")
                            photoCollectionSubject.onNext(assetColl)
                        } else{
                            fail("couldn't find a photo")
                        }
                    }
                    it("shows 1 photo"){
                        expect(imagePageVC.orderedViewControllers.count).to(equal(1))
                    }
                }
                context("many photos"){
                    var assetColl : PHAssetCollection!
                    var assetCount : Int!
                    beforeEach {
                        var assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                        
                        assetCount = assets.count
                        
                        if assets.count > 0 {
                            assetColl = PHAssetCollection.transientAssetCollection(with: [assets.firstObject!], title: "1 photo")
                            photoCollectionSubject.onNext(assetColl)
                        } else{
                            fail("couldn't find a photo")
                        }
                    }
                    it("shows many photos"){
                        expect(imagePageVC.getFetchResultFrom(assetColl)?.count).to(equal(assetCount))
                    }
                }
            }
            context("initally"){
                expect("current path's photo collection is loaded")
                {
                    
                }
            }
        }
    }
}
