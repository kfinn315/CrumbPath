//
//  PathManagerTests.swift
//  pathsTests
//
//  Created by kfinn on 2/19/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RxSwift
import CoreData
import Photos
import RandomKit

@testable import paths

class PathManagerTests: QuickSpec {
    var mockcontext = ContextWrapper()
    override func spec(){
        var expectedPath : Path!
        var actualPath : Path?
        var pathManager: PathManager!
        var disposeBag : DisposeBag!
        var initialPathCount : Int!
        var closureRan : Bool!
        var onNextCalled : Bool!
        
        describe("PathManager"){
            beforeEach {
                //AppDelegate.managedObjectContext = self.mockcontext.context
                pathManager = PathManager()
                
                disposeBag = DisposeBag()
                initialPathCount = self.mockcontext.numberOfPathsInPersistentStore()
            }
            
            context("initally") {
                it("has no current path"){
                    expect(pathManager.currentPath).to(beNil())
                }
                
                //                it("has no current album"){
                //                    expect(pathManager.currentAlbumId).to(beNil())
                //                }
            }
            
            describe("currentPathObservable"){
                
                beforeEach {
                    onNextCalled = false
                    actualPath = nil
                    
                }
                
                context("on subscribing to onNext"){
                    context("currentPath is nil"){
                        beforeEach{
                            expectedPath = nil
                            pathManager.setCurrentPath(expectedPath)
                            waitUntil(action: {done in
                                pathManager.currentPathObservable?.subscribe(onNext: {
                                    path in
                                    onNextCalled = true
                                    actualPath = path as? Path
                                    done()
                                }).disposed(by: disposeBag)
                            })
                        }
                        
                        it("sends nil"){
                            expect(onNextCalled).to(equal(true))
                            expect(actualPath).to(beNil())
                        }
                    }
                    context("currentPath is not nil"){
                        beforeEach{
                            expectedPath = PathTools.generateRandomPath()
                            pathManager.setCurrentPath(expectedPath)
                            waitUntil(action: {done in
                                pathManager.currentPathObservable?.subscribe(onNext: {
                                    path in
                                    onNextCalled = true
                                    actualPath = path as! Path
                                    done()
                                }).disposed(by: disposeBag)
                            })
                        }
                        
                        it("sends the path"){
                            expect(onNextCalled).to(equal(true))
                            expect(actualPath).to(equal(expectedPath))
                        }
                    }
                }
                
                context("current path was updated"){
                    beforeEach{
                        expectedPath = PathTools.generateRandomPath()
                        pathManager.currentPathObservable?.subscribe(onNext: {
                            path in
                            onNextCalled = true
                            actualPath = path as! Path
                            
                        }).disposed(by: disposeBag)
                        pathManager.setCurrentPath(expectedPath)
                        
                    }
                    it("sends the new current path"){
                        expect(onNextCalled).to(equal(true))
                        expect(actualPath).to(equal(expectedPath))
                    }
                    
                    afterEach{
                        expectedPath = nil
                    }
                }
                
                afterEach {
                    onNextCalled = false
                    self.mockcontext.flushPathData()
                }
            }
            describe("saving a mockpath"){
                var actualError : Error!
                var expectedPathId : String!
                var mockPath : MockPath!
                var actualPath : IPath!
                
                beforeEach {
                    closureRan = false
                    actualPath = nil
                    
                    mockPath = MockPath()
                    
                    waitUntil(action: {done in
                        pathManager.save(path: mockPath as? IPath, callback: {(path,error) in
                            actualPath = path
                            expectedPathId = path?.identity
                            closureRan = true
                            actualError = error
                            done()
                        })
                    })
                }
            }
            describe("mock test"){
                var mockPtsMgr = MockPointsManager(context: mockcontext.context)
                var pathmgr = PathManager.init(mockPtsMgr, PhotoManager.shared)
            }
            describe("saving a path") {
                var actualError : Error!
                var expectedPathId : String!
                
                beforeEach {
                    closureRan = false
                    actualPath = nil
                    
                    initialPathCount = self.mockcontext.numberOfPathsInPersistentStore()
                    //add new path to context
                    expectedPath = PathTools.generateRandomPath()
                    
                    waitUntil(action: {done in
                        pathManager.save(path: expectedPath, callback: {(path,error) in
                            actualPath = path as? Path
                            expectedPathId = path?.identity
                            closureRan = true
                            actualError = error
                            done()
                        })
                    })
                }
                
                it("sends new path to subscribers"){
                    expect(actualPath).toNot(beNil())
                    expect(actualPath).to(equal(expectedPath))
                }
                
                it("adds the new path to the ManagedObjectContext"){
                    let paths = pathManager.getAllPaths()
                    expect(paths).toNot(beNil())
                    let actualPath = paths?.filter() { $0.identity == expectedPathId }.first
                    expect(actualPath).toNot(beNil())
                    expect(actualPath).to(equal(expectedPath))
                }
                
                it("sets the hasNewPath property to true"){
                    expect(pathManager.hasNewPath).to(equal(true))
                }
                
                afterEach {
                    self.mockcontext.flushPathData()
                }
            }
            
            describe("Updating a path"){
                //var currentPath : Path!
                var callbackCount : Int = 0
                var expAlbumId : String!
                var expCoverImg : Data!
                var expDistance : NSNumber!
                var expDuration : NSNumber!
                var expTitle : String!
                var expectedId : String!
                var actualId : String!
                
                beforeEach {                    
                    expAlbumId = String.random(ofLength: 6, using: &Xoroshiro.default)
                    expTitle = String.random(ofLength: 8, using: &Xoroshiro.default)
                    expCoverImg = String.random(ofLength: 150, using: &Xoroshiro.default).data(using: String.Encoding.utf8)
                    expDistance = NSNumber.random(using: &Xoroshiro.default)
                    expDuration = NSNumber.random(using: &Xoroshiro.default)
                    
                    
                    callbackCount = 0
                    //add new path to context
                    expectedPath = PathTools.generateRandomPath()
                    waitUntil(action: { (done) in
                        pathManager.save(path: expectedPath, callback: { (path, error) in
                            expectedId = path?.identity
                            initialPathCount = pathManager.getAllPaths()?.count ?? 0
                            pathManager.hasNewPath = false
                            done()
                        })
                    })
                    let callbackexpectation0 = self.expectation(description: "initalCallback")
                    let callbackexpectation1 = self.expectation(description: "update callback")
                    pathManager.currentPathObservable?.subscribe(onNext: {
                        path in
                        onNextCalled = true
                        callbackCount += 1
                        if callbackCount == 1 {
                            do{
                                //update current path with expected path values
                                expectedPath.albumId = expAlbumId
                                expectedPath.coverimg = expCoverImg
                                expectedPath.distance = expDistance
                                expectedPath.duration = expDuration
                                expectedPath.title = expTitle
                                
                                //action
                                try pathManager.updateCurrentPathInCoreData()
                                
                                callbackexpectation0.fulfill()
                            }
                            catch{
                                //error
                            }
                            
                        } else if callbackCount == 2 {
                            actualId = path?.identity
                            callbackexpectation1.fulfill()
                            actualPath = path
                        }
                    }).disposed(by: disposeBag)
                    
                    self.wait(for: [callbackexpectation0,callbackexpectation1], timeout: 50.0)
                }
                
                it("doesn't add a path to the ManagedObjectContext"){
                    expect(actualId).to(equal(expectedId))
                    expect(initialPathCount).to(equal(pathManager.getAllPaths()?.count ?? 0))
                }
                
                it("updates the values of the path in the MOC"){
                    let paths = pathManager.getAllPaths()
                    expect(paths).toNot(beNil())
                    expect(expectedPath?.albumId).toNot(beNil())
                    if let actualPath = paths!.filter({ $0.identity == expectedId}).first {
                        expect(actualPath.albumId).to(equal(expectedPath.albumId))
                        expect(actualPath.coverimg).to(equal(expectedPath.coverimg))
                        expect(actualPath.distance).to(equal(expectedPath.distance))
                        expect(actualPath.duration).to(equal(expectedPath.duration))
                        expect(actualPath.title).to(equal(expectedPath.title))
                    } else{
                        fail("path w/ localid not found")
                    }
                }
                it("sends the update onNext"){
                    //expect onNext was called w/ updated path
                    expect(actualPath).toNot(beNil())
                    expect(expectedPath.albumId).to(equal(expectedPath.albumId))
                    expect(expectedPath.coverimg).to(equal(expectedPath.coverimg))
                    expect(expectedPath.distance).to(equal(expectedPath.distance))
                    expect(expectedPath.duration).to(equal(expectedPath.duration))
                    expect(expectedPath.title).to(equal(expectedPath.title))
                }
                
                it("sets hasNewPath to false"){
                    expect(pathManager.hasNewPath).to(equal(false))
                }
                
                afterEach {
                    self.mockcontext.flushPathData()
                }
            }
        }
    }
}
