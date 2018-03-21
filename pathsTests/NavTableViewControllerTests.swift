//
//  NavTableTests.swift
//  pathsTests
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import XCTest
import Quick
import Nimble
import CoreLocation
import CoreData
import RandomKit
import RxSwift
import RxCocoa
import RxDataSources
import RxCoreData

@testable import paths

class NavTableViewControllerTests: QuickSpec {
    override func spec(){
        var navTable: NavTableViewController!
        var window : UIWindow!
        var coreData : ContextWrapper!
        var tableView : UITableView!
        var pathManager : PathManager!
        var onEndUpdatesCallback : (()->())!
        
        describe("NavTableViewController"){
            beforeEach {
                window = UIWindow(frame: UIScreen.main.bounds)
                coreData = ContextWrapper()
                PathManager.managedObjectContext = coreData.context!
                
                navTable = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: NavTableViewController.storyboardID) as! NavTableViewController
                
                navTable.onEndUpdates = onEndUpdatesCallback
                
                window.set(root: navTable)
                tableView = navTable.tableView
                pathManager = PathManager.shared
                //currentPathObservable = pathManager.currentPathObservable
            }
            
            describe("datasource"){
                var numberOfPaths : Int!
                
                beforeEach{
                    numberOfPaths = Int.random(in: 5...15, using: &Xoroshiro.default)
                    _ = coreData.populatePathsRandomly(count: numberOfPaths)
                }
                
                it("has the right number of paths"){
                    expect(numberOfPaths).to(equal(coreData.numberOfPathsInPersistentStore()))
                }
            }
            describe("the tableview") {
                var numberOfPaths : Int!
                var pathsInCoreData : [Path]!
                var timesCalled : Int!
                context("random data"){
                    beforeEach {
                        timesCalled = 1
                        waitUntil(timeout: 30, action: { (done) in
                        onEndUpdatesCallback = {
                            //each path is added individually so this callback will occur n times
                            //but will only be done on the nth
                            print("t\(timesCalled) of \(numberOfPaths)")
                            if(timesCalled == numberOfPaths)
                            {
                                done()
                            }
                            timesCalled! += 1
                        }
                        navTable.onEndUpdates = onEndUpdatesCallback
                        numberOfPaths = Int.random(in: 5...10, using: &Xoroshiro.default)
                            print("#Paths = \(numberOfPaths)")
                        pathsInCoreData = coreData.populatePathsRandomly(count: numberOfPaths)
                        })
                        
                    }
                    it("has gte 1 section"){
                        expect(tableView.dataSource?.numberOfSections!(in: tableView)).toEventually(beGreaterThan(0))
                    }
                    
                    it("has lte 1 row"){
                        expect(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0)).toEventually(beGreaterThan(0))
                    }
                    it("has a random indexpath"){
                        expect(self.getRandomIndexPath(tableView: tableView)).toEventuallyNot(beNil())
                    }
                    describe("when a row is clicked"){
                        var clickedPath : Path?
                        var indexPath : IndexPath?
                        
                        beforeEach {
                            do{
                                indexPath = self.getRandomIndexPath(tableView: tableView)
                               
                                if let indexPath = indexPath {
                                    clickedPath = try tableView.rx.model(at: indexPath)
                                    navTable.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
                                    navTable.tableView.delegate?.tableView!(tableView, didSelectRowAt: indexPath)
                                }
                                
                            } catch{
                                fail(error.localizedDescription)
                            }
                        }
                        
                        it("sets the clicked Path as the Current Path"){
                            //wait for table to finish updating
                            expect(tableView.dataSource?.numberOfSections!(in: tableView)).toEventually(beGreaterThan(0))
                            
                            expect(pathManager?.pathCount).toEventually(beGreaterThan(0))
                            expect(indexPath).toEventuallyNot(beNil())
                            
                            guard PathManager.shared.currentPath != nil else {
                                fail("currentPath is nil")
                                return
                            }
                            
                            if let clickedPath = clickedPath {
                                expect(PathManager.shared.currentPath!.identity).toEventually(equal(clickedPath.identity))
                            } else {
                                fail("clickedPath is nil")
                            }
                        }
                        
                        xit("launches the PageViewController"){
                            expect(window.visibleViewController()).toEventually(beAKindOf(PageViewController.self), timeout: 30)
                        }
                    }
                }
                describe("map paths to dates") {
                    //var paths : [Path]!
                    var dates : [Date]!
                    var sections : [AnimatableSectionModel<String, Path>]!
                    
                    beforeEach {
                        //paths = []
                        dates = []
                        sections = []
                        
                        numberOfPaths = Int.random(in: 5...15, using: &Xoroshiro.default)
                        pathsInCoreData = coreData.populatePathsRandomly(count: numberOfPaths)
                    }
                    
                    describe("one date"){
                        var date : Date!
                        beforeEach {
                            date = Date.random(using: &Xoroshiro.default)
                            for var path in pathsInCoreData {
                                path.startdate = date
                            }
                            
                            sections = navTable.mapPathsToDates(pathsInCoreData)
                        }
                        
                        it("should have one section"){
                            expect(sections.count).to(equal(1))
                        }
                        it("should have the correct number of total paths"){
                            expect(sections.count).to(equal(1))
                            expect(sections[0].items.count).to(equal(pathsInCoreData.count))
                        }
                    }
                    
                    describe("a different date for each path"){
                        var actualSectionCount : Int!
                        beforeEach {
                            var generator = Date.randoms(using: &Xoroshiro.default)
                            for var path in pathsInCoreData {
                                path.startdate = generator.next()!
                            }
                            
                            sections = navTable.mapPathsToDates(pathsInCoreData)
                            
                            actualSectionCount = 0
                            for var section in sections {
                                actualSectionCount! += section.items.count
                            }
                        }
                        
                        it("should have a section for each path"){
                            expect(sections.count).to(equal(pathsInCoreData.count))
                        }
                        it("should have the correct number of total paths"){
                            expect(actualSectionCount).to(equal(pathsInCoreData.count))
                        }
                    }
                    
                    describe("one date for every 2 paths"){
                        var actualPathCount : Int!
                        beforeEach {
                            var generator = Date.randoms(using: &Xoroshiro.default)
                            var i = 0
                            for var path in pathsInCoreData {
                                if i%2 == 0, let randomDate = generator.next() {
                                    dates.append(randomDate)
                                }
                                path.startdate = dates.last
                                i += 1
                            }
                            
                            sections = navTable.mapPathsToDates(pathsInCoreData)
                            
                            actualPathCount = 0
                            
                            for var section in sections {
                                actualPathCount! += section.items.count
                            }
                        }
                        
                        it("should have a section for each date"){
                            expect(sections.count).to(equal(dates.count))
                        }
                        it("should have the correct number of total paths"){
                            expect(actualPathCount).to(equal(pathsInCoreData.count))
                        }
                    }
                }
            }
            
            
            describe("when the add bar button is clicked"){
                beforeEach {
                    UIApplication.shared.sendAction(navTable.addBarButton.action!, to: navTable.addBarButton.target, from: self, for: nil)
                }
                
                it("launches the 'NewPathViewController'"){
                    if let presentedVC = window.visibleViewController() {
                        expect(presentedVC).to(beAKindOf(NewPathViewController.self))
                    } else{
                        fail("vc not presented or not a kind of NewPathViewController")
                    }
                    
                    
                }
            }
            
            describe("when the all maps bar button is clicked"){
                beforeEach {
                    UIApplication.shared.sendAction(navTable.allBarButton.action!, to: navTable.allBarButton.target, from: self, for: nil)
                }
                
                it("launches the 'AllMap'"){
                    if let presentedVC = window.visibleViewController() {
                        expect(presentedVC).to(beAKindOf(AllMapViewController.self))
                    } else{
                        fail("vc not presented or not a kind of AllMapViewController")
                    }
                }
                
            }
            describe("when the all about button is clicked"){
                beforeEach {
                    UIApplication.shared.sendAction(navTable.aboutBarButton.action!, to: navTable.aboutBarButton.target, from: self, for: nil)
                }
                
                it("launches the 'Info'"){
                    if let presentedVC = window.visibleViewController(){
                        expect(presentedVC).to(beAKindOf(InformationViewController.self))
                    } else{
                        fail("vc not presented or not a kind of InformationViewController")
                    }
                }
            }
        }
    }
    
    func getRandomIndexPath(tableView: UITableView) -> IndexPath?{
        var indexPath : IndexPath?
        
        let randomSection = Int.random(in: 0..<tableView.numberOfSections, using: &Xorshift.default)
        
        if randomSection != nil, let randomRow = Int.random(in: 0..<tableView.numberOfRows(inSection: randomSection!), using: &Xorshift.default) {
            indexPath = IndexPath(row: randomRow, section: randomSection!)
        }
        
        return indexPath
    }
    
}
