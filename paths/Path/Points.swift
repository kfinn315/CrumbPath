//
//  Points.swift
//  paths
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import CoreLocation

public protocol IPoints {
    init(data: Array<Point>)
    
    func getDistance(_ callback: @escaping (CLLocationDistance) -> Void)
    func getLocationDescription(_ callback: @escaping (String?) -> Void )
    func getJSON() throws -> String?
}

public class Points : IPoints {
    var data : Array<Point>!
    
    public required init(data: Array<Point>) {
        self.data = data
    }
    
    public func getDistance(_ callback: @escaping (CLLocationDistance) -> Void){
        var distance : CLLocationDistance = 0.0
        
        var i = 0
        var start : CLLocation?
        
        while(i < data.count ) {
            if i == 0 {
                start = data[i].location
            } else{
                distance += start!.distance(from: data[i].location)
                log.verbose("\(i) \(distance)")
                start = data[i].location
            }
            i += 1
        }
        
        callback(distance)
    }

    public func getLocationDescription(_ callback: @escaping (String?) -> Void ) {
        //get location names
        if let point1 = data.first {
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
        let pointsJSON = String(data: try JSONEncoder().encode(data), encoding: .utf8)
        log.verbose("points: \(pointsJSON ?? "nil")")
        return pointsJSON
    }
}

extension Point {
    var location : CLLocation {
        return CLLocation(self.coordinates)
    }
}
