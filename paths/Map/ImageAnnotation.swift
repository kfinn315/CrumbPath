//
//  ImageAnnotation.swift
//  paths
//
//  Created by Kevin Finn on 2/25/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import Photos

/**
 Map Annotation that displays an image and title
 */
class ImageAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var image : UIImage?
    var asset : PHAsset?
    var title: String?
    var subtitle: String?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.subtitle = nil
        self.image = nil
    }
}

class ImageAnnotationView : MKAnnotationView {
    static var reuseIdentifier = "imagePin"
    private var imageView: UIImageView!
    var assetId : Int32?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.addSubview(self.imageView)
        
        self.imageView.layer.cornerRadius = 5.0
        self.imageView.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var image: UIImage? {
        get {
            return self.imageView.image
        }
        
        set {
            self.imageView.image = newValue
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.image = nil
        self.assetId = nil
    }
}
