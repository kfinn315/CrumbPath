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
import CoreLocation

@objc(Path)
public class Path: NSManagedObject, Persistable, IdentifiableType {
    let decoder = JSONDecoder()
    
    public typealias Identity = String
    
    public typealias T = NSManagedObject
    
    public static var entityName: String = "Path"
        
    var entitydescription : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Path", in: PathManager.managedObjectContext!)!
    }
    
    public var identity: Identity {
        if self.localid == nil {
            self.localid = UUID().uuidString
        }
        return self.localid!
    }
    
    //insert the object into AppDelegate.managedObjectContext
    public required init() {
        super.init(entity: entitydescription, insertInto: nil)
    }
    
    @objc public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: context)
      //  self.localid = UUID().uuidString
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
    
    public required init(_ context: NSManagedObjectContext) {
        super.init(entity: entitydescription, insertInto: context)

        self.localid = UUID().uuidString
    }
    
    public func setTimes(start: Date, end: Date){
        self.startdate = start
        self.enddate = end
        self.duration = DateInterval(start: startdate!, end: enddate!).duration as NSNumber
    }
    
    public static var primaryAttributeName: String {
        return "localid"
    }
    
    public func update(_ entity: T) {
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
    
    public func setPoints(_ points: Points){
        do{
            self.pointsJSON = try points.getJSON()
        } catch{
            log.error(error.localizedDescription)
        }
        
        points.getDistance() { distance in
            self.distance = distance as NSNumber
        }
        points.getLocationDescription() { locality in
            self.locations = locality
        }
        getSteps { (stepcount) in
            self.stepcount = stepcount
        }
        getSnapshot() { coverimage in
            if let coverImg = coverimage {
                log.info("Set cover image")
                self.coverimg = UIImagePNGRepresentation(coverImg)
            }
        }
    }
}
