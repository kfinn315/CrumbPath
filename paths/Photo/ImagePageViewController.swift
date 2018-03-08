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
 
 class ImagePageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public static let storyboardID = "ImagePage"
    
    weak var photoManager = PhotoManager.shared
    
    var disposeBag = DisposeBag()
    private var fetchResult: PHFetchResult<PHAsset>?
    
    func assetAt(_ index: Int) -> PHAsset?{
        if fetchResult != nil, index < fetchResult!.count, index >= 0 {
            return fetchResult?.object(at: index) ?? nil
        } else{
            return nil
        }
    }
    private(set) lazy var orderedViewControllers: [ImageViewController] = { [weak self] in
        if let storyboard = self?.storyboard {
            
            let views = [storyboard.instantiateViewController(withIdentifier: ImageViewController.storyboardID) as! ImageViewController,
                         storyboard.instantiateViewController(withIdentifier: ImageViewController.storyboardID) as! ImageViewController,
                         storyboard.instantiateViewController(withIdentifier: ImageViewController.storyboardID) as! ImageViewController]
            var i = 0
            for var viewI in views {
                viewI.assetIndex = i
                viewI.asset = assetAt(i)
                i = i+1
                
                if self != nil {
                    viewI.view.frame = self!.view.frame
                }
            }
            
            return views
        }
        
        return []
        }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        self.title = ""
        
        self.dataSource = self
        self.delegate = self
        
        setViewControllers([orderedViewControllers.first!], direction: .forward, animated: true, completion: nil)
        
        photoManager = PhotoManager.shared
        
        photoManager?.currentAlbum?.subscribe(onNext: { [unowned self] assetcollection in
            guard self.photoManager?.isAuthorized ?? false else{
                return
            }
            
            if assetcollection == nil {
                self.fetchResult = nil
            } else {
                self.fetchResult = self.photoManager?.fetchAssets(in: assetcollection!, options: nil)
                
                if let fetchResult = self.fetchResult, let firstPage = self.orderedViewControllers.first {
                    firstPage.photoHelper.startCaching(fetchResult)
                    
                    //disable scrolling and paging controller if there is 1 or 0 images
                    if fetchResult.count <= 1 {
                        self.dataSource = nil
                    }
                    else {
                        self.dataSource = self
                    }

                    DispatchQueue.main.async {
                        firstPage.setAsset(asset: fetchResult.firstObject, assetIndex: 0)
                        
                    }
                    
                }
            }
                
            }).disposed(by: disposeBag)
            
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
                //            orderedViewControllers[nextIndex] = prevVC
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
                //orderedViewControllers[nextIndex] = nextVC
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
 
 
