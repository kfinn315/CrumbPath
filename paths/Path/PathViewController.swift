//
//  PathViewController.swift
//  paths
//
//  Created by Kevin Finn on 3/6/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PathViewController : UIViewController {
    static let storyboardID = "pathViewController"
    
    private weak var pathManager = PathManager.shared
    
    @IBOutlet weak var constraintStatsTopMargin: NSLayoutConstraint!
    @IBOutlet weak var circle0: CircleLabelView!
    @IBOutlet weak var circle1: CircleLabelView!
    @IBOutlet weak var circle2: CircleLabelView!
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vwTop: UIView!
    @IBOutlet weak var vwBottom: UIView!
    @IBOutlet weak var btnPhotos: UIButton!
    @IBOutlet weak var vwMap: UIButton!
    @IBOutlet weak var stackStats: UIStackView!
    
    @IBOutlet weak var constraintTopBarHeight: NSLayoutConstraint!
    
    private var disposeBag = DisposeBag()
    
    private lazy var topViewController : UIViewController = {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: MapViewController.storyboardID) as! MapViewController
        
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var bottomViewController : UIViewController = {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: ImagePageViewController.storyboardID) as! ImagePageViewController
        add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        constraintTopBarHeight.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pathManager?.currentPathObservable?.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] path in
            self?.updateUI(path)
        }).disposed(by: disposeBag)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        constraintStatsTopMargin.constant = -1*stackStats.frame.height/2.0
        
    }
    
    private func updateView() {
        add(asChildViewController: topViewController)
        add(asChildViewController: bottomViewController)
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    func updateUI(_ path: Path?){
        self.lblTitle.text = path?.displayTitle
        self.lblLocation.text = path?.locations
        
        if path?.stepcount == nil {
            stackStats.arrangedSubviews[0].isHidden = true
        } else {
            stackStats.arrangedSubviews[0].isHidden = false
            self.circle0.lblTop.text = path?.stepcount!.formatted
        }
        
        if path?.distance == nil {
            stackStats.arrangedSubviews[1].isHidden = true
        } else{
            stackStats.arrangedSubviews[1].isHidden = false
            self.circle1.lblTop.text = path?.displayDistance
        }
        
        if path?.duration == nil {
            stackStats.arrangedSubviews[2].isHidden = true
        } else{
            stackStats.arrangedSubviews[2].isHidden = false
            self.circle2.lblTop.text = path?.displayDuration
        }
    }
}
