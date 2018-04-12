//
//  Route+CoreDataClass.swift
//
//
//  Created by Kevin Finn on 3/20/18
//
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

@objc(Route)
public class Route: NSManagedObject, Persistable, IdentifiableType {
    let decoder = JSONDecoder()
    
    public typealias Identity = String
    
    public typealias T = NSManagedObject
    
    public static var entityName: String = "Route"
    
    static var entitydescription : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Route", in: PathManager.managedObjectContext!)!
    }
    
    public var identity: Identity {
        if self.localid == nil {
            self.localid = UUID().uuidString
        }
        return self.localid!
    }
    
    //insert the object into AppDelegate.managedObjectContext
    public required init() {
        super.init(entity: Route.entitydescription, insertInto: nil)
    }
    
    @objc public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: context)
        //  self.localid = UUID().uuidString
    }
    
    public required init(entity: T) {
        super.init(entity: Route.entitydescription, insertInto: nil)
        
        localid = entity.value(forKey: "localid") as? String
        title = entity.value(forKey: "title") as? String
    }
    
    public required init(_ context: NSManagedObjectContext) {
        super.init(entity: Route.entitydescription, insertInto: context)
        
        self.localid = UUID().uuidString
    }
    
    public static var primaryAttributeName: String {
        return "localid"
    }
    
    public func update(_ entity: T) {
        entity.setValue(title, forKey: "title")
        
        do {
            try entity.managedObjectContext?.save()
        } catch {
            log.error(error.localizedDescription)
        }
    }
}

