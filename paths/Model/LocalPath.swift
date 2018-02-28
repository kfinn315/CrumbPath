//
//  LocalPath.swift
//  paths
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation

public class LocalPath : Equatable {
    var localid: String?
    
    var title: String?
    
    var notes: String?
    
    var startdate: Date
    
    var enddate: Date
    
    var duration: NSNumber?
    
    var distance: NSNumber?
    
    var stepcount: NSNumber?
    
    var pointsJSON: String?
    
    var albumId: String?
    
    var coverimg: Data?
    
    var locations: String?
    init() {
        startdate = Date()
        enddate = Date()
    }
    convenience init(title: String, notes: String? = nil, albumId: String? = nil) {
        self.init()
        
        self.title = title
        self.notes = notes
        self.albumId = albumId
    }
    
    public func equalTo(_ b: LocalPath) -> Bool{
        return self.title == b.title && self.notes == b.notes && self.albumId == b.albumId
    }
}



public func ==(lhs: LocalPath, rhs: LocalPath) -> Bool {
    return lhs.equalTo(rhs)
}
