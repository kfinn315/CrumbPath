//
//  PointManagerTests.swift
//  pathsTests
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//


import XCTest
import Quick
import Nimble
import RxSwift
import CoreData

@testable import paths

class PointManagerTests: QuickSpec {
    override func spec(){
        var subject: PointsManager!
        
        describe("PointsManager"){
            beforeEach {
                subject = PointsManager()
            }

            describe("saving a point"){
                it("adds the point to the database"){
                    
                }
            }
            
            describe("clearing all points"){
                it("removes all points from the database"){
                    
                }
            }
            
            describe("fetching points"){
                it("returns all the points in the database"){
                    
                }
            }
        }
    }
}

