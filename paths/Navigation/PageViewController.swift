 //
//  PageViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/1/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit

 /**
  PageViewController that displays the current Path on 3 pages.
  */
class PageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public static let storyboardID = "PageView"
    var pageControl : UIPageControl
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    private(set) lazy var orderedViewControllers: [UIViewController] = { [weak self] in
        var viewcontrollers : [UIViewController] = []
        if let storyboard = self?.storyboard {
            viewcontrollers = [storyboard.instantiateViewController(withIdentifier: PathViewController.storyboardID),
                    EditPathViewController()]
//                    storyboard.instantiateViewController(withIdentifier: PhotosViewController.storyboardID) as! PhotosViewController]
            var i = 0
            for var views in viewcontrollers {
                views.view.tag = i
                i += 1
            }
        }

        return viewcontrollers
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
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(editPath)), animated: true)
        
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
        
        setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
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
        guard let selectedVC = pageViewController.viewControllers?.first else { return }

        let selectedIndex = selectedVC.view.tag
        
        self.pageControl.currentPage = selectedIndex
    }
    func goToPage(index: Int) {
        if index < orderedViewControllers.count {
            self.setViewControllers([orderedViewControllers[index]], direction: .forward, animated: true, completion: nil)
            self.pageControl.currentPage = index
        }
    }
    public func showFirstPage(){
        if let firstController = orderedViewControllers.first {
            self.setViewControllers([firstController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    @objc func editPath() {
        goToPage(index: 1)
    }
}
