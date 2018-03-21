//
//  AlbumsTableViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/18/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift
import RxCocoa

/**
 Displays all the device's photo albums in a collection view
 */
public class AlbumsTableViewController : BasePhotoViewController,  UICollectionViewDataSource, UICollectionViewDelegate {
    public static let storyboardID = "Albums"
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var data : [IPhotoCollection] = []
    
    override func assetAt(_ index: Int) -> PHAsset? {
        return data[index].thumbnailAsset ?? nil
    }
    
    override public func viewDidLoad() {
        imgPadding = 15
        
        super.baseCollectionView = collectionView
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        data = photosManager?.photoCollections ?? []
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if photosManager?.isAuthorized ?? false {
            return 1
        } else{
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = self.data[indexPath.row]
        DispatchQueue.global(qos: .userInitiated).async {
            self.photosManager?.updateCurrentAlbum(collectionid: album.localid)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = data[indexPath.row].thumbnailAsset
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as? AlbumCell ?? AlbumCell()
        
        if asset != nil {
            cell.representedAssetIdentifier = asset!.localIdentifier
            
            imageManager?.requestImage(for: asset!, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == asset!.localIdentifier && image != nil {
                    cell.ivImage.image = image
                }
            })
        } else {
            cell.ivImage.image = nil
        }
        return cell
    }
}
