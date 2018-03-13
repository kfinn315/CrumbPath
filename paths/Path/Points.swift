//
//  Points.swift
//  paths
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import CoreLocation

public typealias Points = [Point]

/**
 Extension methods for a Point array which format or perform calculations
 */
extension Array where Element:Point {
    public func getDistance(_ callback: @escaping (CLLocationDistance) -> Void){
        var distance : CLLocationDistance = 0.0
        
        var i = 0
        var start : CLLocation?
        
        while(i < self.count ) {
            if i == 0 {
                start = self[i].location
            } else{
                distance += start!.distance(from: self[i].location)
                log.verbose("\(i) \(distance)")
                start = self[i].location
            }
            i += 1
        }
        
        callback(distance)
    }

    public func getLocationDescription(_ callback: @escaping (String?) -> Void ) {
        //get location names
        if let point1 = self.first {
            CLGeocoder().reverseGeocodeLocation(CLLocation(point1.coordinates), completionHandler: { (placemarks, error) in
                var locationData : [String] = []
                
                if let sublocality = placemarks?[0].subLocality {
                    locationData.append(sublocality)
                }
                
                if let locality = placemarks?[0].locality {
                    locationData.append(locality)
                }

                callback(locationData.joined(separator: ", "))
            } )
        }
    }
    
    public func getJSON() throws -> String? {
        let pointsJSON = String(data: try JSONEncoder().encode(self), encoding: .utf8)
        log.verbose("points: \(pointsJSON ?? "nil")")
        return pointsJSON
    }
}

extension Point {
    var location : CLLocation {
        return CLLocation(self.coordinates)
    }
}
