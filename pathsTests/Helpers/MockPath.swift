//
//  MockPath.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/21/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import CoreData
import Foundation
import CoreLocation
import UIKit

public class MockPath : IPath {
    var invokedEntitydescriptionGetter = false
    var invokedEntitydescriptionGetterCount = 0
    var stubbedEntitydescription: NSEntityDescription!
    var entitydescription : NSEntityDescription {
        invokedEntitydescriptionGetter = true
        invokedEntitydescriptionGetterCount += 1
        return stubbedEntitydescription
    }
    var invokedIdentityGetter = false
    var invokedIdentityGetterCount = 0
    var stubbedIdentity: String! = ""
    var identity : String {
        invokedIdentityGetter = true
        invokedIdentityGetterCount += 1
        return stubbedIdentity
    }
    var invokedDisplayTitleGetter = false
    var invokedDisplayTitleGetterCount = 0
    var stubbedDisplayTitle: String! = ""
    var displayTitle : String {
        invokedDisplayTitleGetter = true
        invokedDisplayTitleGetterCount += 1
        return stubbedDisplayTitle
    }
    var invokedDisplayDurationGetter = false
    var invokedDisplayDurationGetterCount = 0
    var stubbedDisplayDuration: String! = ""
    var displayDuration : String {
        invokedDisplayDurationGetter = true
        invokedDisplayDurationGetterCount += 1
        return stubbedDisplayDuration
    }
    var invokedDisplayDistanceGetter = false
    var invokedDisplayDistanceGetterCount = 0
    var stubbedDisplayDistance: String!
    var displayDistance : String? {
        invokedDisplayDistanceGetter = true
        invokedDisplayDistanceGetterCount += 1
        return stubbedDisplayDistance
    }
    var invokedLocalidSetter = false
    var invokedLocalidSetterCount = 0
    var invokedLocalid: String?
    var invokedLocalidList = [String?]()
    var invokedLocalidGetter = false
    var invokedLocalidGetterCount = 0
    var stubbedLocalid: String!
    var localid : String? {
        set {
            invokedLocalidSetter = true
            invokedLocalidSetterCount += 1
            invokedLocalid = newValue
            invokedLocalidList.append(newValue)
        }
        get {
            invokedLocalidGetter = true
            invokedLocalidGetterCount += 1
            return stubbedLocalid
        }
    }
    var invokedTitleSetter = false
    var invokedTitleSetterCount = 0
    var invokedTitle: String?
    var invokedTitleList = [String?]()
    var invokedTitleGetter = false
    var invokedTitleGetterCount = 0
    var stubbedTitle: String!
    var title : String? {
        set {
            invokedTitleSetter = true
            invokedTitleSetterCount += 1
            invokedTitle = newValue
            invokedTitleList.append(newValue)
        }
        get {
            invokedTitleGetter = true
            invokedTitleGetterCount += 1
            return stubbedTitle
        }
    }
    var invokedNotesSetter = false
    var invokedNotesSetterCount = 0
    var invokedNotes: String?
    var invokedNotesList = [String?]()
    var invokedNotesGetter = false
    var invokedNotesGetterCount = 0
    var stubbedNotes: String!
    var notes : String? {
        set {
            invokedNotesSetter = true
            invokedNotesSetterCount += 1
            invokedNotes = newValue
            invokedNotesList.append(newValue)
        }
        get {
            invokedNotesGetter = true
            invokedNotesGetterCount += 1
            return stubbedNotes
        }
    }
    var invokedStartdateSetter = false
    var invokedStartdateSetterCount = 0
    var invokedStartdate: Date?
    var invokedStartdateList = [Date?]()
    var invokedStartdateGetter = false
    var invokedStartdateGetterCount = 0
    var stubbedStartdate: Date!
    var startdate : Date? {
        set {
            invokedStartdateSetter = true
            invokedStartdateSetterCount += 1
            invokedStartdate = newValue
            invokedStartdateList.append(newValue)
        }
        get {
            invokedStartdateGetter = true
            invokedStartdateGetterCount += 1
            return stubbedStartdate
        }
    }
    var invokedEnddateSetter = false
    var invokedEnddateSetterCount = 0
    var invokedEnddate: Date?
    var invokedEnddateList = [Date?]()
    var invokedEnddateGetter = false
    var invokedEnddateGetterCount = 0
    var stubbedEnddate: Date!
    var enddate : Date? {
        set {
            invokedEnddateSetter = true
            invokedEnddateSetterCount += 1
            invokedEnddate = newValue
            invokedEnddateList.append(newValue)
        }
        get {
            invokedEnddateGetter = true
            invokedEnddateGetterCount += 1
            return stubbedEnddate
        }
    }
    var invokedDurationSetter = false
    var invokedDurationSetterCount = 0
    var invokedDuration: NSNumber?
    var invokedDurationList = [NSNumber?]()
    var invokedDurationGetter = false
    var invokedDurationGetterCount = 0
    var stubbedDuration: NSNumber!
    var duration : NSNumber? {
        set {
            invokedDurationSetter = true
            invokedDurationSetterCount += 1
            invokedDuration = newValue
            invokedDurationList.append(newValue)
        }
        get {
            invokedDurationGetter = true
            invokedDurationGetterCount += 1
            return stubbedDuration
        }
    }
    var invokedDistanceSetter = false
    var invokedDistanceSetterCount = 0
    var invokedDistance: NSNumber?
    var invokedDistanceList = [NSNumber?]()
    var invokedDistanceGetter = false
    var invokedDistanceGetterCount = 0
    var stubbedDistance: NSNumber!
    var distance : NSNumber? {
        set {
            invokedDistanceSetter = true
            invokedDistanceSetterCount += 1
            invokedDistance = newValue
            invokedDistanceList.append(newValue)
        }
        get {
            invokedDistanceGetter = true
            invokedDistanceGetterCount += 1
            return stubbedDistance
        }
    }
    var invokedStepcountSetter = false
    var invokedStepcountSetterCount = 0
    var invokedStepcount: NSNumber?
    var invokedStepcountList = [NSNumber?]()
    var invokedStepcountGetter = false
    var invokedStepcountGetterCount = 0
    var stubbedStepcount: NSNumber!
    var stepcount : NSNumber? {
        set {
            invokedStepcountSetter = true
            invokedStepcountSetterCount += 1
            invokedStepcount = newValue
            invokedStepcountList.append(newValue)
        }
        get {
            invokedStepcountGetter = true
            invokedStepcountGetterCount += 1
            return stubbedStepcount
        }
    }
    var invokedPointsJSONSetter = false
    var invokedPointsJSONSetterCount = 0
    var invokedPointsJSON: String?
    var invokedPointsJSONList = [String?]()
    var invokedPointsJSONGetter = false
    var invokedPointsJSONGetterCount = 0
    var stubbedPointsJSON: String!
    var pointsJSON : String? {
        set {
            invokedPointsJSONSetter = true
            invokedPointsJSONSetterCount += 1
            invokedPointsJSON = newValue
            invokedPointsJSONList.append(newValue)
        }
        get {
            invokedPointsJSONGetter = true
            invokedPointsJSONGetterCount += 1
            return stubbedPointsJSON
        }
    }
    var invokedAlbumIdSetter = false
    var invokedAlbumIdSetterCount = 0
    var invokedAlbumId: String?
    var invokedAlbumIdList = [String?]()
    var invokedAlbumIdGetter = false
    var invokedAlbumIdGetterCount = 0
    var stubbedAlbumId: String!
    var albumId : String? {
        set {
            invokedAlbumIdSetter = true
            invokedAlbumIdSetterCount += 1
            invokedAlbumId = newValue
            invokedAlbumIdList.append(newValue)
        }
        get {
            invokedAlbumIdGetter = true
            invokedAlbumIdGetterCount += 1
            return stubbedAlbumId
        }
    }
    var invokedCoverimgSetter = false
    var invokedCoverimgSetterCount = 0
    var invokedCoverimg: Data?
    var invokedCoverimgList = [Data?]()
    var invokedCoverimgGetter = false
    var invokedCoverimgGetterCount = 0
    var stubbedCoverimg: Data!
    var coverimg : Data? {
        set {
            invokedCoverimgSetter = true
            invokedCoverimgSetterCount += 1
            invokedCoverimg = newValue
            invokedCoverimgList.append(newValue)
        }
        get {
            invokedCoverimgGetter = true
            invokedCoverimgGetterCount += 1
            return stubbedCoverimg
        }
    }
    var invokedLocationsSetter = false
    var invokedLocationsSetterCount = 0
    var invokedLocations: String?
    var invokedLocationsList = [String?]()
    var invokedLocationsGetter = false
    var invokedLocationsGetterCount = 0
    var stubbedLocations: String!
    var locations : String? {
        set {
            invokedLocationsSetter = true
            invokedLocationsSetterCount += 1
            invokedLocations = newValue
            invokedLocationsList.append(newValue)
        }
        get {
            invokedLocationsGetter = true
            invokedLocationsGetterCount += 1
            return stubbedLocations
        }
    }
    var invokedInit = false
    var invokedInitCount = 0
    init() {
        invokedInit = true
        invokedInitCount += 1
    }
    var invokedInitEntity = false
    var invokedInitEntityCount = 0
    var invokedInitEntityParameters: (entity: NSManagedObject, Void)?
    var invokedInitEntityParametersList = [(entity: NSManagedObject, Void)]()
    init(entity: NSManagedObject) {
        invokedInitEntity = true
        invokedInitEntityCount += 1
        invokedInitEntityParameters = (entity, ())
        invokedInitEntityParametersList.append((entity, ()))
    }
    var invokedInitNSManagedObjectContext = false
    var invokedInitNSManagedObjectContextCount = 0
    var invokedInitNSManagedObjectContextParameters: (context: NSManagedObjectContext, Void)?
    var invokedInitNSManagedObjectContextParametersList = [(context: NSManagedObjectContext, Void)]()
    init(_ context: NSManagedObjectContext) {
        invokedInitNSManagedObjectContext = true
        invokedInitNSManagedObjectContextCount += 1
        invokedInitNSManagedObjectContextParameters = (context, ())
        invokedInitNSManagedObjectContextParametersList.append((context, ()))
    }
    var invokedSetPoints = false
    var invokedSetPointsCount = 0
    var invokedSetPointsParameters: (points: IPoints, Void)?
    var invokedSetPointsParametersList = [(points: IPoints, Void)]()
    func setPoints(_ points: IPoints) {
        invokedSetPoints = true
        invokedSetPointsCount += 1
        invokedSetPointsParameters = (points, ())
        invokedSetPointsParametersList.append((points, ()))
    }
    var invokedSetTimes = false
    var invokedSetTimesCount = 0
    var invokedSetTimesParameters: (start: Date, end: Date)?
    var invokedSetTimesParametersList = [(start: Date, end: Date)]()
    func setTimes(start: Date, end: Date) {
        invokedSetTimes = true
        invokedSetTimesCount += 1
        invokedSetTimesParameters = (start, end)
        invokedSetTimesParametersList.append((start, end))
    }
    var invokedSave = false
    var invokedSaveCount = 0
    func save() {
        invokedSave = true
        invokedSaveCount += 1
    }
    var invokedUpdate = false
    var invokedUpdateCount = 0
    var invokedUpdateParameters: (entity: NSManagedObject, Void)?
    var invokedUpdateParametersList = [(entity: NSManagedObject, Void)]()
    func update(_ entity: NSManagedObject) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdateParameters = (entity, ())
        invokedUpdateParametersList.append((entity, ()))
    }
    var invokedGetSimplifiedCoordinates = false
    var invokedGetSimplifiedCoordinatesCount = 0
    var stubbedGetSimplifiedCoordinatesResult: [CLLocationCoordinate2D]! = []
    func getSimplifiedCoordinates() -> [CLLocationCoordinate2D] {
        invokedGetSimplifiedCoordinates = true
        invokedGetSimplifiedCoordinatesCount += 1
        return stubbedGetSimplifiedCoordinatesResult
    }
    var invokedGetSteps = false
    var invokedGetStepsCount = 0
    var stubbedGetStepsCallbackResult: (NSNumber?, Void)?
    func getSteps(_ callback: @escaping (NSNumber?) -> Void) {
        invokedGetSteps = true
        invokedGetStepsCount += 1
        if let result = stubbedGetStepsCallbackResult {
            callback(result.0)
        }
    }
    var invokedGetSnapshot = false
    var invokedGetSnapshotCount = 0
    var stubbedGetSnapshotCallbackResult: (UIImage?, Void)?
    func getSnapshot(_ callback: @escaping (UIImage?) -> Void) {
        invokedGetSnapshot = true
        invokedGetSnapshotCount += 1
        if let result = stubbedGetSnapshotCallbackResult {
            callback(result.0)
        }
    }
    var invokedUpdatePhotoAlbum = false
    var invokedUpdatePhotoAlbumCount = 0
    var invokedUpdatePhotoAlbumParameters: (collectionid: String, Void)?
    var invokedUpdatePhotoAlbumParametersList = [(collectionid: String, Void)]()
    func updatePhotoAlbum(collectionid: String) {
        invokedUpdatePhotoAlbum = true
        invokedUpdatePhotoAlbumCount += 1
        invokedUpdatePhotoAlbumParameters = (collectionid, ())
        invokedUpdatePhotoAlbumParametersList.append((collectionid, ()))
    }
}
