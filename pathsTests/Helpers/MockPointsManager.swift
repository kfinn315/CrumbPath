//
//  MockPointsManager.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/22/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import Foundation
import CoreData


class MockPointsManager : IPointsManager {
    var invokedInit = false
    var invokedInitCount = 0
    var invokedInitParameters: (context: NSManagedObjectContext?, Void)?
    var invokedInitParametersList = [(context: NSManagedObjectContext?, Void)]()
    init(context: NSManagedObjectContext?) {
        invokedInit = true
        invokedInitCount += 1
        invokedInitParameters = (context, ())
        invokedInitParametersList.append((context, ()))
    }
    var invokedSavePoint = false
    var invokedSavePointCount = 0
    var invokedSavePointParameters: (point: Point, Void)?
    var invokedSavePointParametersList = [(point: Point, Void)]()
    func savePoint(_ point: Point) {
        invokedSavePoint = true
        invokedSavePointCount += 1
        invokedSavePointParameters = (point, ())
        invokedSavePointParametersList.append((point, ()))
    }
    var invokedClearPoints = false
    var invokedClearPointsCount = 0
    func clearPoints() {
        invokedClearPoints = true
        invokedClearPointsCount += 1
    }
    var invokedFetchPoints = false
    var invokedFetchPointsCount = 0
    var stubbedFetchPointsResult: IPoints!
    func fetchPoints() -> IPoints? {
        invokedFetchPoints = true
        invokedFetchPointsCount += 1
        return stubbedFetchPointsResult
    }
}
