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
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self) as AnyClass)] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "pathsTest", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make it simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition( description.type == NSInMemoryStoreType )
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinator failed \(error)")
            }
        }
        return container
    }()

    func insertPath(local: LocalPath) -> Path? {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: "Path", into: mockPersistantContainer.viewContext) as? Path else {
            return nil
        }
        
        obj.title = local.title
        obj.notes = local.notes
        return obj
    }

    func flushData() {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Path")
        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            mockPersistantContainer.viewContext.delete(obj)
        }
        try! mockPersistantContainer.viewContext.save()
    }
    
    func fetchPaths() throws -> [Path]? {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "Path")
        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest) as? [Path]
        
        return objs
    }
    
    func saveData(){
        do {
                        try mockPersistantContainer.viewContext.save()
                    }  catch {
                        print("create fakes error \(error)")
                    }
    }

    func numberOfItemsInPersistentStore() -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Path")
        let results = try! mockPersistantContainer.viewContext.fetch(request)
        return results.count
    }
    
    override func spec(){
        var subject: PathManager!

        describe("PathManager"){
            beforeEach {
                subject = PathManager()
            }
            
            describe("Initial PathManager") {
                it("has no current path"){
                    expect(subject.currentPath).to(equal(nil))
                }
                
                it("has no current album"){
                    expect(subject.currentAlbumId).to(equal(nil))
                }
            }
            
            describe("changing the CurrentPath"){
                let disposeBag = DisposeBag()
                var path0 : Path?
                var onNextPath : Path?
                //var onNextAlbum : PHAssetCollection?
                
                beforeEach {
                    path0 = self.insertPath(local: LocalPath(title:"0", albumId:"250"))
                    subject.currentPathDriver?.drive(onNext: {
                        path in
                        onNextPath = path
                    }).disposed(by: disposeBag)
                   
                    subject.setCurrentPath(path0)
                }
                
                it("sends new current path to subscribers"){
                    //expect onNext was called w/ updated path
                    expect(path0).toNot(equal(nil))
                    expect(onNextPath).toEventually(equal(path0))
                }
                
                it("sends current album to subscriber"){
                    expect(path0).toNot(equal(nil))
                    //expect(onNextAlbum?.localIdentifier).toEventually(equal(path0?.albumId))
                }
                
                afterEach {
                    self.flushData()
                }
            }
            
            describe("saving a new path"){
                var path0 : LocalPath?
                let disposeBag = DisposeBag()
                var onNextPath : Path?
//                var onNextAlbum : PHAssetCollection?
                var initialPathCount = 0
                
                beforeEach {
                    initialPathCount = self.numberOfItemsInPersistentStore()
                    //add new path to context
                    path0 =  LocalPath(title:"0", albumId:"250")
                    subject.currentPathDriver?.drive(onNext: {
                        path in
                        onNextPath = path
                    }).disposed(by: disposeBag)
                  
                }
                
                it("adds the new path to context"){
                    waitUntil { _ in
                        subject.savePath(start: path0!.startdate, end: path0!.enddate, callback: {(path,error) in
                            expect(path!.title).to(equal(path0!.title))
                    
                    })
                        
                    }

                    expect(self.numberOfItemsInPersistentStore()).to(equal(initialPathCount + 1))

                    //expect to be able to fetch a path with this data
                    do{
                        let paths = try self.fetchPaths()
                        expect(paths).toNot(equal(nil))
                        expect(paths!.count).to(equal(1))
                        expect(paths![0].title).to(equal(path0!.title))
                    } catch{
                        //error
                    }
                }
                
                it("sends new current path to subscribers"){
                    //expect onNext was called w/ updated path
                    expect(path0).toNot(equal(nil))
                    expect(onNextPath!.title).toEventually(equal(path0!.title))
                }
                
                it("sends current album to subscriber"){
                    expect(path0).toNot(equal(nil))
                    //expect(onNextAlbum?.localIdentifier).toEventually(equal(path0?.albumId))
                }
                
                it("sets the hasNewPath property to true"){
                    expect(subject.hasNewPath).to(equal(true))
                }
                
                afterEach {
                    self.flushData()
                }
            }
            
            describe("Updating a path"){
                var path0 : Path?
                let disposeBag = DisposeBag()
                var onNextPath : Path?
                //var onNextAlbum : PHAssetCollection?
                var initialPathCount = 0
                
                beforeEach {
                    initialPathCount = self.numberOfItemsInPersistentStore()
                    //add new path to context
                    path0 = self.insertPath(local: LocalPath(title:"0", albumId:"250"))
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
                    expect(self.numberOfItemsInPersistentStore()).to(equal(initialPathCount))
                    
                    //expect to be able to fetch a path with this data
                    do{
                        let paths = try self.fetchPaths()
                        expect(paths).toNot(equal(nil))
                        expect(paths!.count).to(equal(1))
                        expect(paths![0]).to(equal(path0))
                    } catch{
                        //error
                    }
                }
                
                it("sends new current path to subscribers"){
                    //expect onNext was called w/ updated path
                    expect(path0).toNot(equal(nil))
                    expect(onNextPath).toEventually(equal(path0))
                }
                
                it("sends current album to subscriber"){
                    expect(path0).toNot(equal(nil))
                    //expect(onNextAlbum?.localIdentifier).toEventually(equal(path0?.albumId))
                }
                
                it("sets hasNewPath to false"){
                        expect(subject.hasNewPath).to(equal(false))
                }

                afterEach {
                    self.flushData()
                }
                
            }
        }
    }
}
