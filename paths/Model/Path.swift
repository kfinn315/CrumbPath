//
//  Path+CoreDataClass.swift
//  
//
//  Created by Kevin Finn on 1/17/18.
//
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData
import Photos
import CoreLocation

protocol PathInterface {
    var localid : String? {get set}
    var title : String? {get set}
    var notes : String? {get set}
    var startdate : Date? {get set}
    var enddate : Date? {get set}
    var duration : NSNumber? {get set}
    var distance : NSNumber? {get set}
    var stepcount : NSNumber? {get set}
    var pointsJSON : String? {get set}
    var albumId : String? {get set}
    var coverimg : Data? {get set}
    var locations : String? {get set}
}
@objc(Path)
public class Path: NSManagedObject, PathInterface, Persistable, IdentifiableType {
    let decoder = JSONDecoder()
    
    public typealias Identity = String

    public typealias T = NSManagedObject

    public static var entityName: String = "Path"
    
    public var identity: Identity {
        if self.localid == nil {
            self.localid = UUID().uuidString
        }
        return self.localid!
    }
    
    @objc public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: context)
    }
    
    public required init() {
        super.init(entity: entitydescription, insertInto: nil)
    }

    public required init(entity: T) {
        super.init(entity: entitydescription, insertInto: nil)

        localid = entity.value(forKey: "localid") as? String
        title = entity.value(forKey: "title") as? String
        notes = entity.value(forKey: "notes") as? String
        startdate = entity.value(forKey: "startdate") as? Date
        enddate = entity.value(forKey: "enddate") as? Date
        duration = entity.value(forKey: "duration") as? NSNumber
        distance = entity.value(forKey: "distance") as? NSNumber
        stepcount = entity.value(forKey: "stepcount") as? NSNumber
        pointsJSON = entity.value(forKey: "pointsJSON") as? String
        albumId = entity.value(forKey: "albumId") as? String
        coverimg = entity.value(forKey: "coverimg") as? Data
        locations = entity.value(forKey: "locations") as? String
    }
    
    public required init(_ context: NSManagedObjectContext, _ local: LocalPath) {
        super.init(entity: entitydescription, insertInto: context)
        
        title = local.title
        notes = local.notes
        startdate = local.startdate
        enddate = local.enddate
        duration = local.duration
        distance = local.distance
        stepcount = local.stepcount
        pointsJSON = local.pointsJSON
        locations = local.locations
    }
    
    var entitydescription : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Path", in: AppDelegate.managedObjectContext!)!
    }
    
    public static var primaryAttributeName: String {
        return "localid"
    }
    
    public func update(_ entity: T) {
       // entity.setValue(id, forKey: "id")
        entity.setValue(notes, forKey: "notes")
        entity.setValue(title, forKey: "title")
        entity.setValue(albumId, forKey: "albumId")
        entity.setValue(locations, forKey: "locations")
                
        do {
            try entity.managedObjectContext?.save()
        } catch {            
            log.error(error.localizedDescription)
        }
    }
    
}

