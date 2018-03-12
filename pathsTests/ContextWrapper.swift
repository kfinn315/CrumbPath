//
//  ContextWrapper.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/10/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import CoreData

@testable import paths

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
    //
    //    func generateRandomPath() -> Path {
    //        expectedAlbumId = String.random(ofLength: 6, using: &Xoroshiro.default)
    //        expectedTitle = String.random(ofLength: 8, using: &Xoroshiro.default)
    //        expectedNotes = String.random(ofLength: 8, using: &Xoroshiro.default)
    //
    //        let path = Path(mockcontext, expectedTitle, expectedNotes)
    //        path.albumId = expectedAlbumId
    //
    //        return path
    //    }
}
