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
import RandomKit
import Eureka

@testable import paths

class EditPathViewControllerTests: QuickSpec {
    override func spec(){
        var contextWrapper : ContextWrapper!
        var editPathViewController: EditPathViewController!
        //var mockPathManager : MockPathManager!
        var window : UIWindow!
        var expectedPath : Path!
        var disposeBag : DisposeBag!
        var onNextCalled : Bool!
        var actualPath : Path!
        var pathManager : PathManager!
        
        describe("EditPathViewController"){
            beforeEach {
                expectedPath = nil
                disposeBag = DisposeBag()
                contextWrapper = ContextWrapper()
                
                pathManager = PathManager()
                pathManager.currentPathObservable?.subscribe(onNext: {
                    path in
                    onNextCalled = true
                    actualPath = path
                }).disposed(by: disposeBag)
                window = UIWindow(frame: UIScreen.main.bounds)
                
                editPathViewController = EditPathViewController(pathManager: pathManager)
                
                window.makeKeyAndVisible()
                window.rootViewController = editPathViewController
                
                // Act:
                editPathViewController.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
            }
            describe("the updateForm method"){
                beforeEach {
                    expectedPath = PathTools.generateRandomPath()
                    editPathViewController.updateForm(with: expectedPath)
                }
                it("updates the form to match a Path object"){
                    expectFormDataToEqual(path: expectedPath)
                }
            }
            context("The view appeared"){
                describe("the form") {
                    context("current path is nil"){
                        beforeEach{
                            expectedPath = nil
                            pathManager.setCurrentPath(expectedPath)
                        }
                        it("displays empty fields"){
                            expectFormDataToBeNil()
                        }
                    }
                    
                    context("current path is NOT nil"){
                        beforeEach{
                            expectedPath = PathTools.generateRandomPath()
                            pathManager.setCurrentPath(expectedPath)
                        }
                        it("displays the current path data"){
                            expect(onNextCalled).toEventually(be(true))
                            expectFormDataToEqual(path: actualPath)
                        }
                    }
                    
                    context("the save method runs"){
                        var pathId : String!
                        var completions : Int!
                        var expectedCompletions = 2 //one for nil
                        beforeEach {
                            completions = 0
                            expectedPath = PathTools.generateRandomPath()
                            waitUntil(timeout: 50, action: { done in
                                
                                pathManager.currentPathObservable?.subscribe(onNext: {
                                    path in
                                    onNextCalled = true
                                    completions! += 1
                                    if completions == expectedCompletions {
                                        actualPath = path
                                        pathId = actualPath.localid
                                        generateRandomFormData()
                                        editPathViewController.save()
                                        done()
                                    }
                                }).disposed(by: disposeBag)
                                pathManager.setCurrentPath(expectedPath)
                               
                            })
                            
                        }
                        it("updates the current path  with the updated form values"){
                            expect(onNextCalled).toEventually(equal(true))
                            expectFormDataToEqual(path: actualPath)
                        }
                        it("updates the current path in the Path Manager"){
                            let currentPath = pathManager.currentPath
                            expect(currentPath).toNot(beNil())
                            expectFormDataToEqual(path: currentPath!)
                        }
                    }
                }
            }
        }
        func generateRandomFormData(){
            let form = editPathViewController.form
            
            (form.rowBy(tag: "title") as? TextRow)?.value = String.random(ofLength: 10, using: &Xorshift.default)
            (form.rowBy(tag: "notes") as? TextRow)?.value = String.random(ofLength: 10, using: &Xorshift.default)
            (form.rowBy(tag: "locations") as? TextRow)?.value = String.random(ofLength: 10, using: &Xorshift.default)
            (form.rowBy(tag: "startdate") as? DateRow)?.value = Date.random(using: &Xorshift.default)
            (form.rowBy(tag: "enddate") as? DateRow)?.value = Date.random(using: &Xorshift.default)
            
        }
        func expectFormDataToEqual(path: Path){
            
            expect(editPathViewController.form.rowBy(tag: "title")?.baseValue as! String?).toEventually(equal(path.title))
            expect(editPathViewController.form.rowBy(tag: "notes")?.baseValue as! String?).toEventually(equal(path.notes))
            expect(editPathViewController.form.rowBy(tag: "locations")?.baseValue as! String?).toEventually(equal(path.locations))
            expect(editPathViewController.form.rowBy(tag: "startdate")?.baseValue as! Date?).toEventually(equal(path.startdate))
            expect(editPathViewController.form.rowBy(tag: "enddate")?.baseValue as! Date?).toEventually(equal(path.enddate))
            
        }
        
        func expectFormDataToBeNil(){
            expect(editPathViewController.form.rowBy(tag: "title")?.baseValue as! String?).to(beNil())
            expect(editPathViewController.form.rowBy(tag: "notes")?.baseValue as! String?).to(beNil())
            expect(editPathViewController.form.rowBy(tag: "locations")?.baseValue as! String?).to(beNil())
            expect(editPathViewController.form.rowBy(tag: "startdate")?.baseValue as! Date?).to(beNil())
            expect(editPathViewController.form.rowBy(tag: "enddate")?.baseValue as! Date?).to(beNil())
        }
    }
}
