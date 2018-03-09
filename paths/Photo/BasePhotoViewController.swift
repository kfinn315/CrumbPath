//
//  File.swift
//  paths
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift
import RxCocoa

/** Base class for ViewControllers that display images in a UICollectionView.
 Contains logic for checking permission, retrieving and caching images from Photos
 */
public class BasePhotoViewController : UIViewController {
    weak var baseCollectionView : UICollectionView!
    weak var pathManager = PathManager.shared
    weak var photosManager = PhotoManager.shared
    
    var imageManager : PHCachingImageManager?
    var collectionViewLayout = UICollectionViewFlowLayout()
    var imgPadding : CGFloat = 0.0

    var disposeBag = DisposeBag()
    var thumbnailSize: CGSize = CGSize(width: 50, height: 50)
    
    private lazy var permissionLabel : UILabel = {
        let label = UILabel(frame: CGRect(x:0, y:0, width: self.baseCollectionView.bounds.size.width, height: self.view.bounds.size.height))
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text          = "Please allow this app to access Photos by going to Settings."
        label.font          = label.font.withSize(20)
        return label
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
       
        photosManager?.permissionStatus?.drive(onNext: { [weak self] auth in
            self?.onPermissionChanged(to: auth)
        }).disposed(by: disposeBag)
        
        baseCollectionView.collectionViewLayout = collectionViewLayout
        collectionViewLayout.scrollDirection = .vertical
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        if photosManager?.authorizationStatus == .notDetermined {
            photosManager?.requestPermission()
            showPermissionMessage() //so the view's not empty
        }
        
        updateItemSize()
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateItemSize()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    func onPermissionChanged(to auth: PHAuthorizationStatus){
        if auth == .authorized || auth == .restricted {
            self.imageManager = PHCachingImageManager()
            self.hidePermissionMessage()
        } else {
            self.showPermissionMessage()
        }
        self.reloadData()
    }
    func showPermissionMessage(){
         self.baseCollectionView.backgroundView = self.permissionLabel
    }
    func hidePermissionMessage(){
        if self.baseCollectionView.backgroundView == self.permissionLabel {
            self.baseCollectionView.backgroundView = nil
        }
    }
    func reloadData(){
        self.baseCollectionView.reloadData()
    }
    func assetAt(_ index: Int) -> PHAsset?{
        return nil
    }

    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: baseCollectionView!.contentOffset, size: baseCollectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in baseCollectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in self.assetAt(indexPath.item)}.filter { $0 != nil }.map{ asset in asset!}
        let removedAssets = removedRects
            .flatMap { rect in baseCollectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in self.assetAt(indexPath.item)}.filter { $0 != nil }.map{ asset in asset!}
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager?.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager?.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    func updateItemSize() {
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = viewWidth
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 0
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = view.bounds.size
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        
        thumbnailSize = CGSize(width: itemSize.width * scale - imgPadding, height: itemSize.height * scale - imgPadding)
    }
    fileprivate var previousPreheatRect = CGRect.zero
    
    fileprivate func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

