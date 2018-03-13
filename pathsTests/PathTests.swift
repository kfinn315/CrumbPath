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
                PathManager.managedObjectContext = contextWrapper.context
                
                initialObjectCount = contextWrapper.numberOfPathsInPersistentStore()
                path = Path()
            }
            
            afterEach{
                contextWrapper.flushPathData()
            }
            
            describe("initializing"){
                
                it("doesn't add the new path to the Managed Object Context"){
                    expect(contextWrapper.numberOfPathsInPersistentStore()).to(equal(initialObjectCount))
                }
                
                it("has the 'Path' entity description"){
                    expect(path.entitydescription.managedObjectClassName).to(equal("Path"))
                }
                
                describe("managed properties"){
                    it("is nil"){
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
                        contextWrapper.saveData()
                        let paths = try contextWrapper.fetchPaths()
                        actualPath = paths?.filter(){$0.identity == path.identity }.first
                        
                    } catch{
                        fail(error.localizedDescription)
                    }
                }
                
                it("updates the values for the path"){
                    expect(actualPath).toNot(beNil())
                    
                    // expect(path.isUpdated).to(beTrue())
                    
                    expect(actualPath.albumId).to(equal(randomValues.albumId))
                    expect(actualPath.coverimg).to(equal( randomValues.coverimg))
                    expect(actualPath.title).to(equal(randomValues.title))
                    expect(actualPath.notes).to(equal(randomValues.notes))
                    expect(actualPath.distance).to(equal(randomValues.distance))
                    expect(actualPath.duration).to(equal(randomValues.duration))
                    expect(actualPath.startdate).to(equal(randomValues.startdate))
                    expect(actualPath.enddate).to(equal(randomValues.enddate))
                    expect(actualPath.stepcount).to(equal(randomValues.stepcount))
                    
                }
            }
        }
    }
}
