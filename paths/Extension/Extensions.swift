//
//  UIImageExtension.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/23/17.
//

import UIKit
import CoreGraphics
import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation
import CoreData
import AssetsPickerViewController
import Photos

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }

    /**
     crop to rectangle at the image center
     https://stackoverflow.com/questions/32041420/cropping-image-with-swift-and-put-it-on-center-position
     */
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
    
    
}

extension UIViewController {
    func setClearNav(tintColor: UIColor = UIColor.blue) {
        //        let color = UIColor.HYP_LinkBlue
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:tintColor]
        self.navigationItem.leftBarButtonItem?.tintColor = tintColor
        self.navigationItem.rightBarButtonItem?.tintColor = tintColor
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func isViewVisible() -> Bool {
        return self.viewIfLoaded?.window != nil
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension UINavigationController {
    public func presentTransparentNavigationBar() {
        //        UINavigationBar.appearance().barTintColor = primarycolor
        //        UINavigationBar.appearance().tintColor = secondarycolor
        //        UINavigationBar.appearance().backgroundColor = primarycolor
        //        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: secondarycolor]
        //
        navigationBar.barTintColor = UIColor.clear
        //navigationBar.tintColor = UIColor.clear
        navigationBar.backgroundColor = UIColor.clear
        
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        setNavigationBarHidden(false, animated:true)
        
    }
    
    public func hideTransparentNavigationBar() {
        setNavigationBarHidden(false, animated:false)
        
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for: UIBarMetrics.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
        
        navigationBar.barTintColor = UINavigationBar.appearance().barTintColor
        //navigationBar.tintColor = UINavigationBar.appearance().tintColor
        navigationBar.backgroundColor = UINavigationBar.appearance().backgroundColor
        
        //        if let UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView, statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
        //            statusBar.backgroundColor = UIColor(rgb: 0xFFFC79) //yellow
        //
        //        }
        UIApplication.shared.statusBarStyle = .lightContent
    }
}

extension CLLocation {
    convenience init(_ loc: CLLocationCoordinate2D) {
        self.init(latitude: loc.latitude, longitude: loc.longitude)
    }
}

extension Point {
    convenience init(from location: CLLocation) {
        self.init(id: UUID().uuidString, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, timestamp: location.timestamp)
    }
    
    public var coordinates : CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
    }
    
}
