//
//  PathDetailViewControllerTests.swift
//  pathsTests
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RxSwift
import CoreLocation
import CoreData

@testable import paths

class PathDetailViewControllerTests: QuickSpec {
    override func spec(){
        var subject: PathDetailViewController!
        
        describe("NewPathViewController"){
            
            beforeEach {
                let storyboard = UIStoryboard(name: "main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: PathDetailViewController.storyboardID) as! PathDetailViewController
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.makeKeyAndVisible()
                window.rootViewController = subject
                
                // Act:
                subject.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
                subject.endAppearanceTransition() // Triggers viewDidAppear

            }
                        
            describe("updateUI") {
                context("path is not nil"){
                    let path = Path()
                    subject.updateUI(path)
                    
                    it("shows the path data"){
                        expect(subject.lblTitle.text).to(equal(path.displayTitle))
                        expect(subject.lblDate.text).to(equal(path.startdate?.string))
                        expect(subject.lblSteps.text).to(equal(path.stepcount?.formatted))
                        expect(subject.lblDistance.text).to(equal(path.displayDistance))
                        expect(subject.lblDuration.text).to(equal(path.displayDuration))
                        expect(subject.tvNotes.text).to(equal(path.notes))
                        expect(subject.ivTop.image).toNot(beNil())
                    }
                }
                
                context("path is nil") {
                    let path : Path? = nil
                    subject.updateUI(path)
                    
                    it("shows empty labels"){
                        expect(subject.lblTitle.text).to(equal(""))
                        expect(subject.lblDate.text).to(equal(""))
                        expect(subject.lblSteps.text).to(equal(""))
                        expect(subject.lblDistance.text).to(equal(""))
                        expect(subject.lblDuration.text).to(equal(""))
                        expect(subject.tvNotes.text).to(equal(""))
                        expect(subject.ivTop.image).to(beNil())
                    }
                }
            }
        }
    }
}

