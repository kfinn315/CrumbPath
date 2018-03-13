////
////  PathDetail2VC.swift
////  BreadcrumbsSwift
////
////  Created by Kevin Finn on 1/30/18.
////  Copyright © 2018 Kevin Finn. All rights reserved.
////
//
//import MapKit
//import UIKit
//import RxSwift
//import RxCocoa
//
///**
// Displays details about the current Path
// */
//public class PathDetailViewController : UIViewController {
//    public static let storyboardID = "Detail"
//    private weak var pathManager = PathManager.shared
//
//    @IBOutlet weak var stackvwDuration: UIStackView!
//    @IBOutlet weak var stackvwSteps: UIStackView!
//    @IBOutlet weak var stackvwDist: UIStackView!
//    @IBOutlet weak var ivTop: UIImageView!
//    @IBOutlet weak var lblTitle: UILabel!
//    @IBOutlet weak var lblDate: UILabel!
//    @IBOutlet weak var tvNotes: UITextView!
//    @IBOutlet weak var lblDuration: UILabel!
//    @IBOutlet weak var lblDistance: UILabel!
//    @IBOutlet weak var lblSteps: UILabel!
//
//    private var disposeBag = DisposeBag()
//
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//
//        log.debug("pathDetail view did load")
//        title = ""
//
//        pathManager?.currentPathObservable?.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] path in
//                self?.updateUI(path)
//        }).disposed(by: disposeBag)
//
//    }
//
//    func updateUI(_ path: Path?){
//        if let coverimg = path?.coverimg {
//            self.ivTop.image = UIImage(data: coverimg)
//        }
//
//        self.lblTitle.text = path?.displayTitle
//        self.lblDate.text = "\(path?.dateSpan ?? path?.startdate?.datestring ?? "?")"
//        self.tvNotes.text = "\(path?.notes ?? "")"
//
//        if path?.stepcount == nil {
//            self.stackvwSteps.isHidden = true
//        } else {
//            self.stackvwSteps.isHidden = false
//            self.lblSteps.text = path?.stepcount!.formatted
//        }
//
//        if path?.distance == nil {
//            self.stackvwDist.isHidden = true
//        } else{
//            self.stackvwDist.isHidden = false
//            self.lblDistance.text = path?.displayDistance
//        }
//
//        if path?.duration == nil {
//            self.stackvwDuration.isHidden = true
//        } else{
//            self.stackvwDuration.isHidden = false
//            self.lblDuration.text = path?.displayDuration
//        }
//    }
//
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        log.debug("pathDetail view will appear")
//
//        if #available(iOS 11.0, *) {
//            self.navigationItem.largeTitleDisplayMode = .never
//        } else {
//            // Fallback on earlier versions
//        }
//
//    }
//
//    public override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        //self.ivTop.setRounded()
//
//    }
//
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//    }
//
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        log.debug("pathDetail view will disappear")
//
//    }
//
//    deinit {
//        log.debug("PathDetailVC deinits")
//    }
//
//    public override func didReceiveMemoryWarning() {
//        log.debug("pathDetail view did receive mem warning")
//
//    }
//}

