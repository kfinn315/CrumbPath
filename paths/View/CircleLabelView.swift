//
//  CircleView.swift
//  paths
//
//  Created by Kevin Finn on 3/6/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

/**
 View with a solid-colored circle and a top and bottom label that fit inside.
 */

 class CircleLabelView : UIView {
    
    @IBOutlet weak var constraintCircleWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintCircleHeight: NSLayoutConstraint!
    @IBInspectable var bottomText : String? {
        didSet{
            lblBottom.text = bottomText
        }
    }
    @IBOutlet weak var constraintLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var constraintTopMargin: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ivCircle: CircleImageView!
    @IBOutlet weak var lblTop: UILabel!
    @IBOutlet weak var lblBottom: UILabel!
    @IBInspectable var circleColor : UIColor = UIColor.white{
        didSet{
            ivCircle?.backgroundColor = circleColor
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    func setup(){
        Bundle.main.loadNibNamed("CircleLabelView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        //contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async{
            
            if self.bounds.width < self.bounds.height {
                self.constraintCircleHeight.priority = UILayoutPriority(1)
                self.constraintCircleWidth.priority = UILayoutPriority(999)
            } else {
                self.constraintCircleWidth.priority = UILayoutPriority(1)
                self.constraintCircleHeight.priority = UILayoutPriority(999)
            }
            
            self.setMarginConstraints()
        }
    }
    
    func setMarginConstraints(){
        let width = ivCircle.frame.width
        let radius = width/2.0
        let innerWidth = 2.0*radius/sqrt(2.0)
        let margin = (width - innerWidth)/2
        constraintTopMargin.constant = margin
        constraintLeftMargin.constant = margin
    }
}
