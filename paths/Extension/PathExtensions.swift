import CoreLocation

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
        return title?.isEmpty ?? false ? (locations ?? "-") : title!
    }
    
   public func updatePhotoAlbum(collectionid: String) {
            self.albumId = collectionid
    }
}



