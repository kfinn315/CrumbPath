//
//  RecordingViewControllerTests.swift
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

class RecordingViewControllerTests: QuickSpec {
    override func spec(){
        var subject: RecordingViewController!
        var window : UIWindow!
        
        describe("RecordingViewController"){            
            beforeEach {
                window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: RecordingViewController.storyboardID) as! RecordingViewController
                
                window.makeKeyAndVisible()
                window.rootViewController = subject
                
                // Act:
                subject.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
            }
            
            describe(".viewWillAppear"){
                it("is recording"){
                    //?
                }
                it("sets the start time") {
                    expect(subject.startTime).toNot(beNil())
                }
                it("starts the timer"){
                    expect(subject.timer?.isValid).to(equal(true))
                    expect(subject.timer?.timeInterval).to(equal(1))
                }
            }
            context("after view did appear"){
                beforeEach {
                    subject.endAppearanceTransition() // Triggers viewDidAppear
                }
                
                describe("button stop clicked") {
                    beforeEach {
                        subject.btnStop.sendActions(for: .touchUpInside)
                    }
                    it("shows save alert") {
                        expect(subject?.saveAlert.isBeingPresented).toEventually(equal(true))
                    }
                    it("stops the timer"){
                        expect(subject.timer?.isValid).to(equal(false))
                    }
                    it("sets the stop time") {
                        expect(subject.stopTime).toNot(beNil())
                    }
                }
                
                context("button stop was clicked, save alert is visible") {
                    beforeEach {
                        subject.btnStop.sendActions(for: .touchUpInside)
                    }
                    
                    describe("save button is pressed") {
                        it("dismisses the save alert"){
                            expect(subject?.saveAlert.isBeingDismissed).toEventually(equal(true))
                        }
                        it("shows loading alert"){
                            expect(subject?.loadingActivityAlert.isBeingPresented).toEventually(equal(true))
                        }
                        it("navigates to EditPath"){
                            expect(window.rootViewController).toEventually(beAKindOf(EditPathViewController.self))
                        }
                    }
                    
                    describe("reset button is pressed"){
                        it("dismisses the save alert"){
                            expect(subject?.saveAlert.isBeingDismissed).toEventually(equal(true))
                        }
                        it("navigates back to the New Path view"){
                            expect(window.rootViewController).toEventually(beAKindOf(NewPathViewController.self))
                            
                        }
                    }
                }
            }
        }
    }
}
