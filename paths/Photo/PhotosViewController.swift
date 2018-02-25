import Foundation
import UIKit
import Photos
import RxSwift
import RxCocoa

class PhotosViewController: BasePhotoViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    public static let storyboardID = "Photos Table"

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var fetchResult: PHFetchResult<PHAsset>?
    
    private lazy var imageViewController : ImageViewController? = {
        return storyboard?.instantiateViewController(withIdentifier: ImageViewController.storyboardID) as! ImageViewController?
    }()
    
    private lazy var emptyLabel : UILabel = {
        let label = UILabel(frame: CGRect(x:0, y:0, width: self.baseCollectionView.bounds.size.width, height: self.view.bounds.size.height))
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text          = "Add a photo album to this Path by clicking the '+' button at the top"
        label.font          = label.font.withSize(20)
        return label
    }()
    
    lazy var albumAlert : UIAlertController = {
        let alert = UIAlertController(title: "Import Photo Album", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let actionExisting = UIAlertAction.init(title: "Choose an Existing Album", style: UIAlertActionStyle.default, handler: { [weak self] _ in
            self?.showAlbumsLibrary()
        })
        alert.addAction(actionExisting)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }()
    
    override func viewDidLoad() {
        super.baseCollectionView = collectionView

        super.viewDidLoad()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
       
        photosManager?.currentAlbumDriver?.drive(onNext: { [unowned self] assetcollection in
            guard self.photosManager?.isAuthorized ?? false else{
                return
            }

            if assetcollection == nil {
                self.fetchResult = nil
            } else {
                self.fetchResult = self.photosManager?.fetchAssets(in: assetcollection!, options: nil)
            }
           
            if self.fetchResult?.count ?? 0 == 0{
                self.showEmptyMessage()
            } else{
                self.hideEmptyMessage()
            }
            
            self.collectionView?.reloadData()
            
        }).disposed(by: disposeBag)
    }
    func showEmptyMessage(){
         self.collectionView.backgroundView = self.emptyLabel
    }
    
    func hideEmptyMessage(){
        if self.collectionView.backgroundView == self.emptyLabel {
            self.collectionView.backgroundView = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Get size of the collectionView cell for thumbnail image
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let cellSize = layout.itemSize
            self.thumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }

        super.viewWillAppear(animated)
        
        self.parent?.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(presentAddAlbumView)), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (self.parent as? PageViewController)?.resetNavigationItems()
    }
    
    @objc func presentAddAlbumView(){
        present(albumAlert, animated: true, completion: nil)
    }
    
    override func assetAt(_ index: Int) -> PHAsset?{
        return fetchResult?.object(at: index) ?? nil
    }
    override func onPermissionChanged(to auth: PHAuthorizationStatus) {
        super.onPermissionChanged(to: auth)
        
        if auth == .authorized || auth == .restricted {
            self.parent?.navigationItem.rightBarButtonItem?.isEnabled = true
        } else{
            self.parent?.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if photosManager?.isAuthorized ?? false || self.fetchResult?.count ?? 0 == 0{
            return 1
        } else{
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult?.object(at: indexPath.item)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cameraCell", for: indexPath) as? ImageCollectionViewCell
            else { fatalError("bad cell") }
        
        if asset != nil {
            cell.representedAssetIdentifier = asset!.localIdentifier
            
            imageManager?.requestImage(for: asset!, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == asset!.localIdentifier && image != nil {
                    cell.imageView.image = image
                }
            })
        } else {
            cell.imageView = nil
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout methods
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult?.object(at: indexPath.item)
        
        if asset != nil {
            showFull(asset!)
        }
    }

    private func showFull(_ asset: PHAsset) {
        if let imageViewController = imageViewController{
            imageViewController.asset = asset
            //photovc.assetCollection = assetCollection
            self.parent?.navigationController?.pushViewController(imageViewController, animated: true)
        }
    }
    
    private func showAlbumsLibrary() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: AlbumsTableViewController.storyboardID) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

