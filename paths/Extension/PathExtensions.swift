import CoreLocation
import UIKit
import CoreMotion

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
    
    public var displayDistance : String{
        guard self.distance != nil else {
            return "?"
        }
        
        return self.distance?.formatted ?? "?"
    }
    
    public var displayDuration : String {
        guard duration != nil else {
            return "?"
        }
        let dateFormatter = DateComponentsFormatter()
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
            return locations ?? "-"
        }
        
        return title ?? "?"
    }
    
    public func updatePhotoAlbum(collectionid: String) {
        self.albumId = collectionid
    }
    
    public func getSnapshot(_ callback: @escaping (UIImage?) -> Void){
        MapViewController().getSnapshot(from: self) { snapshot, error in
            log.debug("getting map snapshot")
            guard error == nil else {
                log.error(error!.localizedDescription)
                callback(nil)
                return
            }
            
            callback(snapshot?.image)
        }
    }
    
    
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
}
