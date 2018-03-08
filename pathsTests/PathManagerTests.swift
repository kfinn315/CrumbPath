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

@testable import paths

class PathManagerTests: QuickSpec {
    var mockcontext = ContextWrapper()
    override func spec(){
        var subject: PathManager!
        
        describe("PathManager"){
            beforeEach {
                subject = PathManager()
            }
            
            describe("Initial PathManager") {
                it("has no current path"){
                    expect(subject.currentPath).to(beNil())
                }
                
                it("has no current album"){
                    expect(subject.currentAlbumId).to(beNil())
                }
            }
            
            describe("changing the CurrentPath"){
                let disposeBag = DisposeBag()
                var path0 : Path?
                var onNextPath : Path?
                //var onNextAlbum : PHAssetCollection?
                
                beforeEach {
                    path0 = self.mockcontext.insertPath(local: LocalPath(title:"0", albumId:"250"))
                    subject.currentPathDriver?.drive(onNext: {
                        path in
                        onNextPath = path
                    }).disposed(by: disposeBag)
                    
                    subject.setCurrentPath(path0)
                }
                
                it("sends new current path to subscribers"){
                    //expect onNext was called w/ updated path
                    expect(path0).toNot(beNil())
                    expect(onNextPath).toEventually(equal(path0))
                }
                
                it("sends current album to subscriber"){
                    expect(path0).toNot(beNil())
                    //expect(onNextAlbum?.localIdentifier).toEventually(equal(path0?.albumId))
                }
                
                afterEach {
                    self.mockcontext.flushPathData()
                }
            }
            
            describe("saving a new path"){
                var path0 : LocalPath?
                let disposeBag = DisposeBag()
                var onNextPath : Path?
                //                var onNextAlbum : PHAssetCollection?
                var initialPathCount = 0
                
                beforeEach {
                    initialPathCount = self.mockcontext.numberOfPathsInPersistentStore()
                    //add new path to context
                    path0 =  LocalPath(title:"0", albumId:"250")
                    subject.currentPathDriver?.drive(onNext: {
                        path in
                        onNextPath = path
                    }).disposed(by: disposeBag)
                    
                }
                
                it("adds the new path to context"){
                    waitUntil { done in
                        subject.savePath(start: path0!.startdate, end: path0!.enddate, callback: {(path,error) in
                            expect(path!.title).to(equal(path0!.title))
                            done()
                        })
                        
                    }
                    expect(self.mockcontext.numberOfPathsInPersistentStore()).to(equal(initialPathCount + 1))
                    
                    //expect to be able to fetch a path with this data
                    do{
                        let paths = try self.mockcontext.fetchPaths()
                        expect(paths).toNot(beNil())
                        expect(paths!.count).to(equal(1))
                        if paths!.count > 1 {
                            expect(paths![0].title).to(equal(path0!.title))
                        } else{
                            fail()
                        }
                    } catch{
                        //error
                    }
                }
                
                it("sends new current path to subscribers"){
                    //expect onNext was called w/ updated path
                    expect(path0).toNot(beNil())
                    if onNextPath != nil {
                        expect(onNextPath!.title).toEventually(equal(path0!.title))
                    } else{
                        fail("onNextPath was nil")
                    }
                }
                
                it("sends current album to subscriber"){
                    expect(path0).toNot(beNil())
                    //expect(onNextAlbum?.localIdentifier).toEventually(equal(path0?.albumId))
                }
                
                it("sets the hasNewPath property to true"){
                    expect(subject.hasNewPath).to(equal(true))
                }
                
                afterEach {
                    self.mockcontext.flushPathData()
                }
            }
            
            describe("Updating a path"){
                var path0 : Path?
                let disposeBag = DisposeBag()
                var onNextPath : Path?
                //var onNextAlbum : PHAssetCollection?
                var initialPathCount = 0
                
                beforeEach {
                    initialPathCount = self.mockcontext.numberOfPathsInPersistentStore()
                    //add new path to context
                    path0 = self.mockcontext.insertPath(local: LocalPath(title:"0", albumId:"250"))
                    subject.currentPathDriver?.drive(onNext: {
                        path in
                        onNextPath = path
                    }).disposed(by: disposeBag)
                    
                    do{
                        path0?.title = "1"
                        path0?.albumId = "newts"
                        try subject.updateCurrentPathInCoreData()
                    }
                    catch{
                        //error
                    }
                    
                }
                
                it("doesn't add a new path to context"){
                    expect(self.mockcontext.numberOfPathsInPersistentStore()).to(equal(initialPathCount))
                    
                    //expect to be able to fetch a path with this data
                    do{
                        let paths = try self.mockcontext.fetchPaths()
                        expect(paths).toNot(beNil())
                        expect(paths!.count).to(equal(1))
                        expect(paths![0]).to(equal(path0))
                    } catch{
                        //error
                    }
                }
                
                it("sends new current path to subscribers"){
                    //expect onNext was called w/ updated path
                    expect(path0).toNot(beNil())
                    expect(onNextPath).toEventually(equal(path0))
                }
                
                it("sends current album to subscriber"){
                    expect(path0).toNot(beNil())
                    //expect(onNextAlbum?.localIdentifier).toEventually(equal(path0?.albumId))
                }
                
                it("sets hasNewPath to false"){
                    expect(subject.hasNewPath).to(equal(false))
                }
                
                afterEach {
                    self.mockcontext.flushPathData()
                }
            }
        }
    }
}

class ContextWrapper {
    var context : NSManagedObjectContext?
    
    init(){
        context = setUpInMemoryManagedObjectContext()
    }
    
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    //
    //    lazy var managedObjectModel: NSManagedObjectModel = {
    //        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self) as AnyClass)] )!
    //        return managedObjectModel
    //    }()
    //
    //    lazy var mockPersistantContainer: NSPersistentContainer = {
    //        let container = NSPersistentContainer(name: "pathsTest", managedObjectModel: self.managedObjectModel)
    //        let description = NSPersistentStoreDescription()
    //        description.type = NSInMemoryStoreType
    //        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
    //
    //        container.persistentStoreDescriptions = [description]
    //        container.loadPersistentStores { (description, error) in
    //            // Check if the data store is in memory
    //            precondition( description.type == NSInMemoryStoreType )
    //
    //            // Check if creating container wrong
    //            if let error = error {
    //                fatalError("Create an in-mem coordinator failed \(error)")
    //            }
    //        }
    //        return container
    //    }()
    func saveData(){
        do {
            try context!.save()
        }  catch {
            print("create fakes error \(error)")
        }
    }
    
    //MARK:- Paths
    
    func insertPath(local: LocalPath) -> Path? {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: "Path", into: context!) as? Path else {
            return nil
        }
        
        obj.title = local.title
        obj.notes = local.notes
        return obj
    }
    
    func flushPathData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Path")
        let objs = try! context!.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            context!.delete(obj)
        }
        try! context!.save()
    }
    
    func fetchPaths() throws -> [Path]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Path")
        let objs = try! context!.fetch(fetchRequest) as? [Path]
        
        return objs
    }
    
    
    func numberOfPathsInPersistentStore() -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Path")
        let results = try! context!.fetch(request)
        return results.count
    }
    
    //MARK:= Points
    
    func insertPoint(local: LocalPoint) -> Point? {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: "Point", into: context!) as? Point else {
            return nil
        }
        
        obj.latitude = local.latitude
        obj.longitude = local.longitude
        obj.timestamp = local.timestamp as! Date
        
        return obj
    }
    
    func flushPointData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
        let objs = try! context!.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            context!.delete(obj)
        }
        try! context!.save()
    }
    
    func fetchPoints() throws -> [Point]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
        let objs = try! context!.fetch(fetchRequest) as? [Point]
        
        return objs
    }
    
    
    func numberOfPointsInPersistentStore() -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Point")
        let results = try! context!.fetch(request)
        return results.count
    }
}
