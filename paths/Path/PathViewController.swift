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

/**
 Displays details about the current Path object including in a MapViewController and ImagePageViewController and presents Path editing options.
 */
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
    @IBOutlet weak var stackStats: UIStackView!
    
    private var disposeBag = DisposeBag()
    
    private weak var maps : MapViewController?
    private weak var photos : ImagePageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(showEdit)), animated: true)
        
        for var childViewController in self.childViewControllers {
            if childViewController is MapViewController {
                maps = childViewController as? MapViewController
                maps?.isUserInteractionEnabled = false
            } else if childViewController is ImagePageViewController {
                photos = childViewController as? ImagePageViewController
            }
        }
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(showMap))
        vwTop?.addGestureRecognizer(tapGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pathManager?.currentPathObservable?.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] path in
            self?.updateUI(path)
        }).disposed(by: disposeBag)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            //ensure the StackView is split horizontally above the Title view and the ImagePageViewController
            self.constraintStatsTopMargin.constant = -1*self.stackStats.frame.height/2.0
        }
    }
    @objc func showPhotos(){
        if let vc = storyboard?.instantiateViewController(withIdentifier: PhotosViewController.storyboardID) {
            self.present(vc, animated: true, completion: nil)
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @objc func showEdit(){
        self.navigationController?.pushViewController(EditPathViewController(), animated: true)
    }
    
    @objc func showMap(){
        if let mapModalViewController = storyboard?.instantiateViewController(withIdentifier: MapModalViewController.storyboardID) as? MapModalViewController
        {
            //try to reuse the map view
            if maps != nil {
            mapModalViewController.setMapView(maps!.mapView)
            }
            self.present(mapModalViewController, animated: true, completion: nil)
        }
    }
    func updateUI(_ path: IPath?){
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
