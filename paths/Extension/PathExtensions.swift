import CoreLocation
import UIKit
import CoreMotion
import SwiftSimplify
import MapKit

extension Path {
    var dateSpan : String {
        var spanString = ""
        if self.startdate != nil, self.enddate != nil {
            if(startdate!.datestring == enddate?.datestring) {
                spanString += startdate!.datestring
                spanString += " \(startdate!.timestring) - \(enddate!.timestring)"
            }
        }
        return spanString
    }
    
    public var displayDistance : String?{
        guard self.distance != nil else {
            return nil
        }
        
        if let locationDistance = self.distance as? CLLocationDistance {
            distanceFormatter.units = .imperial
            distanceFormatter.unitStyle = .abbreviated
            return distanceFormatter.string(fromDistance: locationDistance)
        }
        
        return nil
    }
    
    public var displayDuration : String {
        guard duration != nil else {
            return "?"
        }
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        dateFormatter.unitsStyle = .abbreviated
        
        let timeinterval = TimeInterval(truncating: duration!)
        return dateFormatter.string(from: timeinterval) ?? "?"
    }
    
    public func getPoints() -> [CLLocationCoordinate2D] {
        do {
            if let json = (pointsJSON ?? "").data(using: .utf8) {
                let points = try decoder.decode([Point].self, from: json)
                return points.map({(point: Point) -> CLLocationCoordinate2D in return point.coordinates})
            }
        } catch {
            log.error(error.localizedDescription)
        }
        return []
    }
    
    public var displayTitle : String {
        let title = self.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        if title == nil || title!.isEmpty {
            return locations ?? ""
        }
        
        return title ?? ""
    }
    
    public func updatePhotoAlbum(collectionid: String) {
        self.albumId = collectionid
    }
    
    /// Generate a map snapshot
    ///
    /// - Parameter callback: code block to execute when the UIImage returns
    public func getSnapshot(_ callback: @escaping (UIImage?) -> Void){
        MapView.getSnapshot(from: self) { image, error in
            log.debug("getting map snapshot")
            guard error == nil else {
                log.error(error!.localizedDescription)
                callback(nil)
                return
            }
            
            callback(image)
        }
    }
    
    /// Get the number of steps taken between the Path's start and end times
    ///
    /// - Parameter callback: the block of code to execute when the step data returns
    public func getSteps(_ callback: @escaping (NSNumber?) -> Void){
        guard let startdate = startdate, let enddate = enddate else{
            log.debug("getSteps: start or end dates are nil")
            callback(nil)
            return
        }
        
        log.debug("get steps for range \(startdate.string) - \(enddate.string)")
        
        if #available(iOS 11.0, *) {
            let authStatus = CMMotionActivityManager.authorizationStatus()
            
            if authStatus == .authorized || authStatus == .notDetermined, CMPedometer.isStepCountingAvailable() {
                PathManager.pedometer.queryPedometerData(from: startdate, to: enddate) {(data, error) -> Void in
                    var stepcount : NSNumber?
                    log.debug("get steps callback")
                    
                    if error == nil, let stepdata = data {
                        log.verbose("steps: \(stepdata.numberOfSteps)")
                        log.verbose("est distance: \(stepdata.distance ?? 0)")
                        stepcount = stepdata.numberOfSteps
                    } else {
                        log.error("error: \(error?.localizedDescription ?? "error") or step data was nil")
                    }
                    
                    callback(stepcount)
                }
            } else {
                log.error("Core motion is not authorized or step counting is not available")
                callback(nil)
            }
        } else {
            // Fallback on earlier versions
            log.debug("core motion skipped due to iOS version")
            callback(nil)
        }
        
        return
    }
    
    
    /// Simplify the coordinates using SwiftSimplify library
    ///
    /// - Returns: Simplified coordinate array
    func getSimplifiedCoordinates() -> [CLLocationCoordinate2D]{
        // let points = points.getPoints()
        var simpleCoords : [CLLocationCoordinate2D] = []
        
        let coordinates = self.getPoints()
        if coordinates.count > 5 {
            //simplify coordinates
            simpleCoords = SwiftSimplify.simplify(coordinates, tolerance: MapViewDelegate.lineTolerance)
        } else{
            simpleCoords = coordinates
        }
        
        return simpleCoords
    }
}
