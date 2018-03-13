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

protocol PointsManagerInterface {
    init(context: NSManagedObjectContext?)
    func savePoint(_ point: Point)
    func clearPoints()
    func fetchPoints() -> Points
}

/**
 Retrieves and updates the Point objects in CoreData
 */
class PointsManager : PointsManagerInterface {
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
    
    public func fetchPoints() -> Points{
        var points : [Point] = []
        let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
        
        do {
            points = try PathManager.managedObjectContext!.fetch(fetchRequest)
        } catch {
            log.error("error \(error)")
        }
        
        return points
    }
}
