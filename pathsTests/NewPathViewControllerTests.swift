//
//  NewPathViewControllerTests.swift
//  pathsTests
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RxSwift
import CoreLocation
import CoreData

@testable import paths

class NewPathViewControllerTests: QuickSpec {
    override func spec(){
        var subject: NewPathViewController!
        var window : UIWindow!

        describe("NewPathViewController"){
            beforeEach {
                window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: NewPathViewController.storyboardID) as! NewPathViewController
                
                window.makeKeyAndVisible()
                window.rootViewController = subject
                
                // Act:
                subject.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
                subject.endAppearanceTransition() // Triggers viewDidAppear
                
            }
            describe("When the app is not authorized to use location services"){
                it("shows a message directing the user to change the settings"){
                    expect(subject.lblInstructions.text).to(contain("settings"))
                }
                
                it("disables the 'start' button"){
                    expect(subject.btnStart.isUserInteractionEnabled).to(equal(false))
                }
                
                it("disables the quality option bar"){
                    expect(subject.segAction.isUserInteractionEnabled).to(equal(false))
                }
            }
            
            describe("when the app is authorized to use location services"){
                it("enables the 'start' button"){
                    expect(subject.btnStart.isUserInteractionEnabled).to(equal(true))
                }
                
                it("shows instruction message")
                {
                    expect(subject.lblInstructions.text).to(contain("accuracy"))
                }
            }
            
            describe("When the app does not have a location permission set"){
                it("presents the permission dialog"){
                }
            }
            
            describe("When the 'start' button is pressed"){
                beforeEach {
                    subject.btnStart.sendActions(for: .touchUpInside)
                }
                it("shows the Recording view controller"){
                    expect(window.rootViewController).toEventually(beAKindOf(RecordingViewController.self))
                }
            }
        }
    }
}

