//
//  PageViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/1/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit

class PageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var pageControl : UIPageControl
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    private(set) lazy var orderedViewControllers: [UIViewController] = { [weak self] in
        if let storyboard = self?.storyboard {
            return [storyboard.instantiateViewController(withIdentifier: PathDetailViewController.storyboardID),
                    storyboard.instantiateViewController(withIdentifier: MapViewController.storyboardID),
                    storyboard.instantiateViewController(withIdentifier: PhotosViewController.storyboardID) as! PhotosViewController]
        }
        
        return []
    }()
    
    required init?(coder: NSCoder) {
        pageControl = UIPageControl()
        
        super.init(coder: coder)
    }
   
    override func viewDidLoad() {
        self.title = ""
        
        self.dataSource = self
        self.delegate = self
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        showFirstPage()
        
        pageControl.transform = pageControl.transform.rotated(by: .pi/2)
        self.view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                pageControl.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 0),
                pageControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: 0)])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
                pageControl.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                pageControl.topAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0)
                ])
        }
        
        pageControl.numberOfPages = self.orderedViewControllers.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    public func resetNavigationItems() {
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(editPath)), animated: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let nextindex = viewController.view.tag - 1
        
        if nextindex >= 0 {
            return orderedViewControllers[nextindex]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextindex = viewController.view.tag + 1
        
        if nextindex < orderedViewControllers.count {
            return orderedViewControllers[nextindex]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pageViewController.viewControllers?.first?.view?.tag ?? 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // this will get you currently presented view controller
        guard let selectedVC = pageViewController.viewControllers?.first else { return }
        
        // and its index in the dataSource's controllers (I'm using force unwrap, since in my case pageViewController contains only view controllers from my dataSource)
        let selectedIndex = selectedVC.view.tag
        // and we update the current page in pageControl
        self.pageControl.currentPage = selectedIndex
    }
    func goToPage(index: Int) {
        if index < orderedViewControllers.count {
            self.setViewControllers([orderedViewControllers[index]], direction: .forward, animated: false, completion: nil)
            self.pageControl.currentPage = index
        }
    }
    public func showFirstPage(){
        if let firstController = orderedViewControllers.first {
            self.setViewControllers([firstController], direction: .forward, animated: true, completion: nil)
            //self.pageControl.currentPage = 0
        }
    }
    
    @objc func editPath() {
        self.navigationController?.pushViewController(EditPathViewController(), animated: true)
    }
}
