//
//  EditViewControllerTests.swift
//  pathsTests
//
//  Created by Kevin Finn on 2/27/18.
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

class EditPathViewControllerTests: QuickSpec {
    override func spec(){
        var subject: EditPathViewController!
        var mockPathManager : MockPathManager!
        var window : UIWindow!
        
        describe("EditPathViewController"){
            beforeEach {
                mockPathManager = MockPathManager()
                window = UIWindow(frame: UIScreen.main.bounds)
               
                subject = EditPathViewController(pathManager: mockPathManager)
                
                window.makeKeyAndVisible()
                window.rootViewController = subject
                
                // Act:
                subject.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
            }
            
            describe("when the current path is updated"){
                var path : Path!

                beforeEach {
                    path = Path()
                    //set path values here
                    mockPathManager.setCurrentPath(path)
                    //subject should update
                }
                
                it("updates the form fields"){
                    expect(subject.form.rowBy(tag: "title")?.baseValue as! String?).to(equal(path.title))
                    expect(subject.form.rowBy(tag: "notes")?.baseValue as! String?).to(equal(path.notes))
                    expect(subject.form.rowBy(tag: "locations")?.baseValue as! String?).to(equal(path.locations))
                    expect(subject.form.rowBy(tag: "startdate")?.baseValue as! Date?).to(equal(path.startdate))
                    expect(subject.form.rowBy(tag: "enddate")?.baseValue as! Date?).to(equal(path.enddate))
                }
            }
            
            describe("when the update button is pressed"){
                it("updates the values in the current path in the path manager"){
                    
                }
            }
            
            describe("when the back button is pressed"){
                it("returns to previous view"){
                    
                }
            }
        }
    }
}
