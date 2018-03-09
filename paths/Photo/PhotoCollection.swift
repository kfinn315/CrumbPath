import Foundation
import Photos

public protocol IPhotoCollection {
    var collection : PHAssetCollection {get}
    var title : String {get}
    var localid : String {get}
    var thumbnailAsset : PHAsset? {get}
}
/**
 Wrapper for a PHAssetCollection that provides a thumbnail and title for the photo collection
 */
public class PhotoCollection : IPhotoCollection {
    // private static var imageManager = PHImageManager.default()
    
    public var thumbnailAsset: PHAsset?
    
    private var opts = PHFetchOptions()
    
    public var collection : PHAssetCollection
    
    public var title : String {
        return collection.localizedTitle ?? ""
    }
    public var localid : String {
        return collection.localIdentifier
    }
    init(_ collection: PHAssetCollection) {
        self.collection = collection
        
        if #available(iOS 9.0, *) {
            opts.fetchLimit = 1
        }
        
        self.getThumbnail()
    }
    
    private func getThumbnail() {
        let assets = PHAsset.fetchAssets(in: self.collection, options: self.opts)
        
        //get first image to use as collection thumbnail
        thumbnailAsset = assets.firstObject
    }
}
