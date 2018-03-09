import Foundation
import UIKit
import Photos
import RxSwift
import RxCocoa
import AssetsPickerViewController

/**
 Displays a collection of images in a collection view.
 */
class PhotosViewController: BasePhotoViewController, UICollectionViewDataSource, UICollectionViewDelegate, AssetsPickerViewControllerDelegate, AssetsAlbumViewControllerDelegate {

    public static let storyboardID = "Photos Table"

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var fetchResult: PHFetchResult<PHAsset>?
    
    private lazy var imageViewController : ImageViewController? = {
        return storyboard?.instantiateViewController(withIdentifier: ImageViewController.storyboardID) as! ImageViewController?
    }()
    
    private lazy var emptyLabel : UILabel = {
        let label = UILabel(frame: CGRect(x:0, y:0, width: self.baseCollectionView.bounds.size.width, height: self.view.bounds.size.height))
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.text          = "Add a photo album to this Path by clicking the 'Edit' button at the top"
        label.font          = label.font.withSize(20)
        return label
    }()
    
//    lazy var albumAlert : UIAlertController = {
//        let alert = UIAlertController(title: "Import Photo Album", message: "", preferredStyle: UIAlertControllerStyle.alert)
//        let actionExisting = UIAlertAction.init(title: "Pick an Album", style: UIAlertActionStyle.default, handler: { [weak self] _ in
//            self?.showAlbumsLibrary()
//        })
//        let actionCreate = UIAlertAction.init(title: "Select Photos", style: UIAlertActionStyle.default, handler: { _ in self.showPhotosLibrary() }
//        )
//
//        alert.addAction(actionExisting)
//        alert.addAction(actionCreate)
//        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
//
//        return alert
//    }()
    override func viewDidLoad() {
        super.baseCollectionView = collectionView
        
        super.viewDidLoad()
                self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .done, target: nil, action: nil), animated: true)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        doneButton.action = #selector(closeModal)
        editButton.action = #selector(editPhotos)
        photosManager?.currentAlbum?.subscribe(onNext: { [unowned self] assetcollection in
            guard self.photosManager?.isAuthorized ?? false else{
                return
            }
            
            if assetcollection == nil {
                self.fetchResult = nil
            } else {
                self.fetchResult = self.photosManager?.fetchAssets(in: assetcollection!, options: nil)
            }
            
            DispatchQueue.main.async {
                if self.fetchResult?.count ?? 0 == 0{
                    self.showEmptyMessage()
                } else{
                    self.hideEmptyMessage()
                }
                
                self.collectionView?.reloadData()
            }
            
        }).disposed(by: disposeBag)
    }
    @objc func closeModal(){
        self.dismiss(animated: true, completion: nil)
    }
    @objc func editPhotos(){
        showPhotosLibrary()
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
        self.parent?.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(showPhotosLibrary)), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (self.parent as? PageViewController)?.resetNavigationItems()
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
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.albumIsShowEmptyAlbum = false
        pickerConfig.albumIsShowHiddenAlbum = false
        
        let picker = AssetsPickerViewController(pickerConfig: pickerConfig)
        picker.pickerDelegate = self
        
        let albumVC = AssetsAlbumViewController(pickerConfig: pickerConfig)
        albumVC.delegate = self
        let albumNavi = UINavigationController(rootViewController: albumVC)
        albumNavi.modalPresentationStyle = .overCurrentContext
        
        if #available(iOS 11.0, *) {
            albumNavi.navigationBar.prefersLargeTitles = true
        }
        
        picker.modalPresentationStyle = .overCurrentContext
        present(picker, animated: false, completion: nil)
        picker.view.isHidden = true
        picker.present(albumNavi, animated: true, completion: {
            picker.view.isHidden = false
        })
    }
    
    @objc private func showPhotosLibrary(){
        let photoConfig = AssetsPickerConfig()
        photoConfig.albumIsShowEmptyAlbum = false
        photoConfig.albumIsShowHiddenAlbum = false
        photoConfig.assetsMinimumSelectionCount = 0
        photoConfig.selectedAssets = []
        fetchResult?.enumerateObjects({ (asset, count, finish) in
            photoConfig.selectedAssets!.append(asset)
        })
        
        let photoPicker = AssetsPickerViewController(pickerConfig: photoConfig)
        photoPicker.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(erasePhotos)), animated: true)
        photoPicker.pickerDelegate = self
        present(photoPicker, animated: true, completion: nil)
    }
    @objc func erasePhotos() {
        
    }
    //MARK:- AssetsPickerViewControllerDelegate Implementation
    public func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        showEmptyMessage()
    }
    public func assetsPickerDidCancel(controller: AssetsPickerViewController) {}
    public func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        // do your job with selected assets
        //create album with assets, update Path object
        photosManager?.addToCurrent(assets) { (success,error) in
        }
    }
    public func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    public func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {}
    public func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    public func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {}
    
    //MARK:= AssetsAlbumPickerViewControllerDelegate implementation
    func assetsAlbumViewControllerCancelled(controller: AssetsAlbumViewController) {
    }
    
    func assetsAlbumViewController(controller: AssetsAlbumViewController, selected album: PHAssetCollection) {
        photosManager?.updateCurrentAlbum(collectionid: album.localIdentifier)
        dismiss(animated: true, completion: nil)
    }
    override func updateItemSize() {
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 15
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionViewLayout.itemSize = itemSize
        collectionViewLayout.minimumInteritemSpacing = padding
        collectionViewLayout.minimumLineSpacing = padding
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale - imgPadding, height: itemSize.height * scale - imgPadding)
    }
    
}

