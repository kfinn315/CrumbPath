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
import RxCocoa
import CoreLocation
import CoreData

@testable import paths

class MockLocationManager : ILocationManager {
    var authorized: Driver<Bool>
    var location: Driver<CLLocation>
    var isUpdating: Bool = false
    var accuracy: LocationAccuracy = .walking
    init() {
        authorized = BehaviorSubject<Bool>(value: false).asDriver(onErrorJustReturn: false)
        location = BehaviorSubject<CLLocation>(value: CLLocation()).asDriver(onErrorJustReturn: CLLocation())
    }
    func startLocationUpdates(with accuracy: LocationAccuracy) {
    }
    func stopLocationUpdates() {
    }
}
class RecordingViewControllerTests: QuickSpec {
    override func spec(){
        var subject: RecordingViewController!
        var window : UIWindow!
        var mockLM : MockLocationManager!
        describe("RecordingViewController"){            
            beforeEach {
                window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: RecordingViewController.storyboardID) as! RecordingViewController
                
                window.makeKeyAndVisible()
                window.rootViewController = subject
                
                // Act:
            }
            
            describe(".viewWillAppear"){
                beforeEach {
                    subject.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
                }
                it("is recording"){
                    expect(subject.locationManager?.isUpdating).to(equal(true))
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
                    subject.beginAppearanceTransition(true, animated: false) // Triggers  viewWillAppear
                    subject.endAppearanceTransition() // Triggers viewDidAppear
                }
                
                context("stop button was clicked") {
                    beforeEach {
                        subject.btnStop.sendActions(for: .touchUpInside)
                    }
                    it("shows save alert"){
                        expect(subject.presentedViewController).to(equal(subject.saveAlert))
                    }
                    
                    it("doesn't stop the timer"){
                        expect(subject.timer?.isValid).to(equal(true))
                    }
                }
                context("save alert view is displayed") {
                    describe("save button is pressed") {
                        it("saves new path"){
                            waitUntil() { done in
                                subject.save() { path, error in
                                    expect(path).toNot(beNil())
                                    expect(error).to(beNil())
                                    done()
                                }
                            }
                            it("goes to EditPathViewController"){
                                expect(window.rootViewController).toEventually(beAKindOf(EditPathViewController.self))
                            }
                        }
                        describe("reset button is pressed"){
                            it("navigates back to the New Path view"){
                                expect(window.rootViewController).toEventually(beAKindOf(NewPathViewController.self))
                            }
                        }
                        describe("cancel button was pressed"){
                            it("closes the alert"){
                                expect(subject.presentedViewController).to(beNil())
                            }
                        }
                    }
                }
            }
        }
    }
}
