//
//  MockPath.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/10/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//
import RandomKit
import CoreData
import Nimble

@testable import paths

class PathTools {
    
    public static func generateRandomPath() -> Path {
        var path : Path!
        
        path = Path()

        path.albumId = String.random(ofLength: 6, using: &Xoroshiro.default)
        path.title = String.random(ofLength: 8, using: &Xoroshiro.default)
        path.notes = String.random(ofLength: 8, using: &Xoroshiro.default)
        path.startdate = Date.random(in: Date.distantPast...Date(), using: &Xoroshiro.default)
        path.enddate = Date.random(in: path.startdate!...Date(), using: &Xoroshiro.default)
        path.locations = String.random(ofLength: 10, using: &Xoroshiro.default)
        path.pointsJSON = String.random(ofLength: 150, using: &Xoroshiro.default)
        path.coverimg = String.random(ofLength: 150, using: &Xoroshiro.default).data(using: String.Encoding.utf8)
        path.distance = NSNumber.random(using: &Xoroshiro.default)
        path.duration = NSNumber.random(using: &Xoroshiro.default)
        path.stepcount = NSNumber.random(using: &Xoroshiro.default)
        return path
    }
    
    public static func expectPathValuesAreEqual(path1: Path, path2: Path) {
        expect(path1.albumId == path2.albumId)
        expect(path1.coverimg == path2.coverimg)
        expect(path1.title == path2.title)
        expect(path1.notes == path2.notes)
        expect(path1.distance == path2.distance)
        expect(path1.duration == path2.duration)
        expect(path1.startdate == path2.startdate)
        expect(path1.enddate == path2.enddate)
        expect(path1.stepcount == path2.stepcount)
    }
    
    
}

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc is UINavigationController {
            
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.visibleViewController!)
            
        } else if vc is UITabBarController {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.presentedViewController!)
                
            } else {
                
                return vc;
            }
        }
    }
}
