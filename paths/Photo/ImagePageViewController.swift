 //
 //  PageViewController.swift
 //  BreadcrumbsSwift
 //
 //  Created by Kevin Finn on 2/1/18.
 //  Copyright © 2018 Kevin Finn. All rights reserved.
 //
 
 import UIKit
 import Photos
 import RxSwift
 import RxCocoa
 
 /** PageViewController that displays full screen images from fetchResult, a PHFetchResult<PHAsset> object  
  */
 class ImagePageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public static let storyboardID = "ImagePage"
    
    weak var photoManager : IPhotoManager? = PhotoManager.shared
    var disposeBag = DisposeBag()
    
    private var fetchResult: PHFetchResult<PHAsset>? {
        didSet{
            updatePager()
        }
    }
    
    func assetAt(_ index: Int) -> PHAsset?{
        if fetchResult != nil, index < fetchResult!.count, index >= 0 {
            return fetchResult?.object(at: index) ?? nil
        } else{
            return nil
        }
    }
    
    private(set) lazy var orderedViewControllers: [ImageViewController] = { [weak self] in
        if let storyboard = self?.storyboard {
            var views : [ImageViewController] = []
            
            for var i in 0..<3 {
                var viewController = storyboard.instantiateViewController(withIdentifier: ImageViewController.storyboardID) as! ImageViewController
                viewController.assetIndex = i
                viewController.asset = assetAt(i)
                
                if self != nil {
                    viewController.view.frame = self!.view.frame
                }
                
                views.append(viewController)
            }
            
            return views
        }
        
        return []
        }()
    
    override func viewDidLoad() {
        photoManager = PhotoManager.shared
        self.title = ""
        
        self.dataSource = self
        self.delegate = self
        
        setViewControllers([orderedViewControllers.first!], direction: .forward, animated: true, completion: nil)
        
        photoManager?.currentStatusAndAlbum?.asDriver(onErrorJustReturn: (.notDetermined, nil)).drive(onNext: { [unowned self] (authStatus, assetCollection) in
            if authStatus == .denied {
                //don't have permission
                log.verbose("ImagePage vc doesn't have photo permission")
            } else if authStatus == .notDetermined {
                //ask
                log.verbose("ImagePage vc should ask for photo permission")
            } else{
                //has permission
                self.fetchResult = self.getFetchResultFrom(assetCollection)
            }
        }).disposed(by: disposeBag)
        
        //add a tap gesture recognizer
        view.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFullScreen)))
    }
    
    @objc public func showFullScreen(){
        if let pathViewController = parent as? PathViewController {
            pathViewController.showPhotos()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = self.view.frame
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if photoManager?.authorizationStatus == .notDetermined {
            photoManager?.requestPermission()
            //showPermissionMessage() //so the view's not empty
        }
        
        // updateItemSize()
        orderedViewControllers.first?.photoHelper.assetSize = self.view.frame.size
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // updateItemSize()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // updateCachedAssets()
    }
    
    func getFetchResultFrom(_ assetcollection: PHAssetCollection?) -> PHFetchResult<PHAsset>?{
        
        var fetchResult : PHFetchResult<PHAsset>?
        
        if assetcollection == nil {
            fetchResult = nil
        } else {
            fetchResult = self.photoManager?.fetchAssets(in: assetcollection!, options: nil)
        }
        return fetchResult
    }
    func updatePager(){
        if let fetchResult = self.fetchResult, let firstPage = self.orderedViewControllers.first {
            firstPage.photoHelper.startCaching(fetchResult)
            
            DispatchQueue.main.async {
                //disable scrolling and paging controller if there is 1 or 0 images
                if fetchResult.count == 0 {
                    self.dataSource = nil
                    firstPage.setAsset(asset: nil, assetIndex: 0)
                    firstPage.showEmptyMessage()
                } else {
                    if fetchResult.count == 1 {
                        self.dataSource = nil
                    } else {
                        self.dataSource = self
                    }
                    firstPage.hideEmptyMessage()
                    firstPage.setAsset(asset: fetchResult.firstObject, assetIndex: 0)
                    
                }
            }
        }
    }
    
    //MARK:- UIPageViewControllerDataSource implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentVC = viewController as! ImageViewController
        guard let viewControllerIndex = orderedViewControllers.index(of: currentVC) else {
            return nil
        }
        
        let prevAssetIndex = (currentVC.assetIndex ?? 0) - 1
        var prevIndex = viewControllerIndex - 1
        if prevIndex < 0 {
            prevIndex = orderedViewControllers.count - 1
        }
        
        if let prevAsset =  assetAt(prevAssetIndex) {
            let prevVC = orderedViewControllers[prevIndex]
            log.info("load previous asset index \(prevAssetIndex)")
            prevVC.asset = prevAsset
            prevVC.assetIndex = prevAssetIndex
            return prevVC
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentVC = viewController as! ImageViewController
        guard let viewControllerIndex = orderedViewControllers.index(of: currentVC) else {
            return nil
        }
        
        var nextIndex = viewControllerIndex + 1
        if nextIndex == orderedViewControllers.count {
            nextIndex = 0
        }
        let nextAssetIndex = (currentVC.assetIndex ?? 0) + 1
        
        if let nextAsset =  assetAt(nextAssetIndex) {
            let nextVC = orderedViewControllers[nextIndex]
            log.info("load nexgt asset index \(nextAssetIndex)")
            nextVC.asset = nextAsset
            nextVC.assetIndex = nextAssetIndex
            return nextVC
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pageViewController.viewControllers?.first?.view.tag ?? 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed { return }
        DispatchQueue.main.async() {
            pageViewController.dataSource = nil
            pageViewController.dataSource = self
        }
    }
 }
 
 
