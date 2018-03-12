//
//  PathTests.swift
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
import CoreData
import CoreLocation

@testable import paths

class PathTests: QuickSpec {
    
    override func spec(){
        var contextWrapper : ContextWrapper!
        var path: Path!
        
        describe("Path"){
            var initialObjectCount : Int!
            
            beforeEach {
                contextWrapper = ContextWrapper()
                AppDelegate.managedObjectContext = contextWrapper.context
                
                initialObjectCount = contextWrapper.numberOfPathsInPersistentStore()
                path = Path()
            }
            
            afterEach{
                contextWrapper.flushPathData()
            }
            
            describe("initializing"){
                
                it("doesn't add the new path to the Managed Object Context"){
                    var currentObjectCount = contextWrapper.numberOfPathsInPersistentStore()
                    expect(currentObjectCount).to(equal(initialObjectCount))
                }
                
                it("has the 'Path' entity description"){
                    expect(path.entitydescription.managedObjectClassName).to(equal("Path"))
                }
                
                describe("path's object id"){
                    it("isn't nil"){
                        expect(path.objectID).toNot(beNil())
                    }
                    
                    it("equals Identity"){
                        expect(path.identity).to(equal(path.objectID.uriRepresentation().absoluteString))
                    }
                }
                
                describe("managed properties"){
                    it("nil"){
                        expect(path.albumId).to(beNil())
                        expect(path.coverimg).to(beNil())
                        expect(path.distance).to(beNil())
                        expect(path.duration).to(beNil())
                        expect(path.enddate).to(beNil())
                        expect(path.startdate).to(beNil())
                        expect(path.locations).to(beNil())
                        expect(path.pointsJSON).to(beNil())
                    }
                }
            }
            
            describe("after initializing"){
                
                beforeEach {
                }
            }
            
            describe("initializing with a MOC"){
                
            }
            
            describe("saving the path"){
                beforeEach{
                    path = PathTools.generateRandomPath()
                    contextWrapper.context?.insert(path)
                }
                
                it("is inserted into the managed context" ){
                        expect(path.isInserted).to(beTrue())
                }
                
                it("can be retrieved from the managed context"){
                    do{
                        let paths = try contextWrapper.fetchPaths()
                        let actualpath = paths?.filter(){$0.identity == path.identity }.first
                        expect(actualpath).to(equal(path))
                    } catch{
                        fail()
                    }
                }
            }
            
            describe("updating the path"){
                var randomValues : Path!
                var actualPath : Path!
                
                beforeEach {
                    path = PathTools.generateRandomPath()
                    contextWrapper.context?.insert(path)
                    
                    randomValues = PathTools.generateRandomPath()
                    
                    path.albumId = randomValues.albumId
                    path.coverimg = randomValues.coverimg
                    path.title = randomValues.title
                    path.notes = randomValues.notes
                    path.distance = randomValues.distance
                    path.duration = randomValues.duration
                    path.startdate = randomValues.startdate
                    path.enddate = randomValues.enddate
                    path.stepcount = randomValues.stepcount
                    
                    do{
                        try contextWrapper.context?.save()
                            let paths = try contextWrapper.fetchPaths()
                        actualPath = paths?.filter(){$0.identity == path.identity }.first
                        
                    } catch{
                        fail("error thrown")
                    }
                }
                
                it("updates the values for the path"){
                   // expect(path.isUpdated).to(beTrue())
                    
                    PathTools.expectPathValuesAreEqual(path1: actualPath, path2: randomValues)
                }
            }
        }
    }
}
