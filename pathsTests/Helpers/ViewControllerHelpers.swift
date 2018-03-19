//
//  ViewControllerHelpers.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/14/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func triggerViewWillAppear(){
        self.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
    }
    
    func triggerViewDidAppear(){
        self.endAppearanceTransition() // Triggers viewDidAppear
    }
}

extension UIWindow {
    func set(root: UIViewController){
        self.makeKeyAndVisible()
        self.rootViewController = root
    }
}
