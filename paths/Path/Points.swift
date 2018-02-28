//
//  Points.swift
//  paths
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import CoreLocation

public typealias Points = [Point]

extension Array where Element:Point {
    public func getDistance(_ callback: @escaping (CLLocationDistance) -> Void){  
        var pointDistance : (endPoint: CLLocation?, distance: CLLocationDistance) = (nil, 0.0)
        pointDistance = self.reduce(into: pointDistance, { (pointDistance, point) in
            if(pointDistance.endPoint != nil){ //first
                pointDistance.distance += pointDistance.endPoint!.distance(from: CLLocation(point.coordinates))
                log.verbose("distance \(pointDistance.distance)")
            }
            pointDistance.endPoint = CLLocation(point.coordinates)
        })
        callback(pointDistance.distance)
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
