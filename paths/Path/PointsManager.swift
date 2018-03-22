//
//  CoreDataManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/1/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import UIKit

protocol IPointsManager {
    init(context: NSManagedObjectContext?)
    func savePoint(_ point: Point)
    func clearPoints()
    func fetchPoints() -> IPoints?
}

/**
 Retrieves and updates the Point objects in CoreData
 */
class PointsManager : IPointsManager {
    weak var context : NSManagedObjectContext?
    
    convenience init() {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
        self.init(context: context)
    }
    
    required init(context: NSManagedObjectContext?) {
        self.context = context
    }
    
    func savePoint(_ point: Point) {
        log.debug("savePoint")
        
        guard context != nil else {
            return
        }
        
        context!.insert(point)
        do{
            try context!.save()
        } catch{
            log.error(error.localizedDescription)
        }
    }
    
    func clearPoints() {
        log.debug("clearPoints")
        
        guard context != nil else {
            return
        }
        
        context!.perform {
            [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
                try localcontext!.execute(request)
            } catch {
                log.error("error \(error)")
            }            
        }
    }
    
    public func fetchPoints() -> IPoints?{
        var points : IPoints?
        let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "timestamp", ascending: true)]
        do {
            let pointsData = try PathManager.managedObjectContext!.fetch(fetchRequest)
            points = Points(data: pointsData)
        } catch {
            log.error("error \(error)")
        }
        
        return points
    }
}
