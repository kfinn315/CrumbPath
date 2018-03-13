//
//  CircleImageView.swift
//  paths
//
//  Created by Kevin Finn on 2/27/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import UIKit

/**
 Circular ImageView. It can also be used as a solid-colored circle.
 */
 class CircleImageView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
//    override init(image: UIImage?) {
//        super.init(image: image)
//        setup()
//    }
//    override init(image: UIImage?, highlightedImage: UIImage?) {
//        super.init(image: image, highlightedImage: highlightedImage)
//        setup()
//    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        
    }
    func setup(){
        clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var leastDimension : CGFloat!
        if bounds.width < bounds.height {
            leastDimension = bounds.width
        } else {
            leastDimension = bounds.height
        }

        bounds = CGRect(origin: bounds.origin, size: CGSize(width: leastDimension, height: leastDimension))

        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
    }
}
