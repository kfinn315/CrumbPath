//
//  PointsTest.swift
//  pathsTests
//
//  Created by Kevin Finn on 2/26/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import XCTest
import Quick
import Nimble
import CoreLocation

@testable import paths

class PointsTest: QuickSpec {
    let mocWrapper = ContextWrapper()
    override func spec() {
        var subject : Points!
        Path.managedObjectContext = mocWrapper.context

        describe("Points") {
            describe("after initialized") {
                beforeEach {
                    subject = Points()
                }
                describe("a description for a point in limerick ireland"){
                    beforeEach {
                        subject.append(Point(insertInto: self.mocWrapper.context!, from: CLLocation(latitude: 52.6680204, longitude: -8.630497600000012)))
                    }
                    it("contains 'limerick'"){
                        var location : String?
                        
                        subject.getLocationDescription({ (description) in
                            location = description
                        })
                        expect(location).toEventually(contain("Limerick"))
                    }
                }
                
                describe("it calculate distance") {
                    var expectedDistance : CLLocationDistance!
                    context("2 points") {
                        beforeEach {
                            let locations = [CLLocation(latitude: 32.9697, longitude: -96.80322), CLLocation(latitude: 29.46786,longitude: -98.53506)]
                            
                            expectedDistance = self.getDistance(locations)
                            
                            for var location in locations {
                                subject.append(Point(insertInto:self.mocWrapper.context!, from: location))
                            }
                        }
                        
                        it("returns the distance"){
                            waitUntil { done in
                                subject.getDistance() { (distance) in                            expect(distance).to(equal(expectedDistance as CLLocationDistance))
                                    done()
                                }
                            }
                        }
                    }
                    
                    describe("0 points") {
                        subject = []
                        
                        it("returns 0") {
                            waitUntil { done in
                                subject.getDistance() { (distance) in                            expect(distance).to(equal(0.0))
                                    done()
                                }
                            }
                        }
                    }
                    
                    describe("1 point") {
                        beforeEach {
                            let locations = [CLLocation(latitude: 32.9697, longitude: -96.80322)]
                            
                            for var location in locations {
                                subject.append(Point(insertInto:self.mocWrapper.context!, from: location))
                            }
                        }
                        
                        it("returns 0"){
                            waitUntil { done in
                                subject.getDistance() { (distance) in                            expect(distance).to(equal(0.0))
                                    done()
                                }
                            }
                        }
                    }
                    
                    describe("identical points") {
                        beforeEach {
                            let locations = [CLLocation(latitude: 32.9697, longitude: -96.80322),
                                             CLLocation(latitude: 32.9697, longitude: -96.80322),
                                             CLLocation(latitude: 32.9697, longitude: -96.80322),
                                             CLLocation(latitude: 32.9697, longitude: -96.80322),
                                             CLLocation(latitude: 32.9697, longitude: -96.80322),
                                             CLLocation(latitude: 32.9697, longitude: -96.80322),
                                             CLLocation(latitude: 32.9697, longitude: -96.80322)
                            ]
                            
                            for var location in locations {
                                subject.append(Point(insertInto:self.mocWrapper.context!, from: location))
                            }
                        }
                        it("returns 0"){
                            waitUntil { done in
                                subject.getDistance() { (distance) in                            expect(distance).to(equal(0.0))
                                    done()
                                }
                            }
                        }
                        
                        describe("20 random points") {
                            var expected : CLLocationDistance!
                            
                            beforeEach {
                                var locations : [CLLocation] = []
                                
                                var i = 0
                                let max = 20
                                
                                while(i < max) {
                                    locations.append(CLLocation(self.generateRandomCoordinates(min: UInt32(0), max: UInt32(2))))
                                    log.debug("coord \(locations[i])")
                                    i += 1
                                }
                                
                                expected = self.getDistance(locations)
                                
                                for var location in locations {
                                    subject.append(Point(insertInto:self.mocWrapper.context!, from: location))
                                }
                            }
                            
                            it("returns the distance between the points") {
                                waitUntil { done in
                                    subject.getDistance() { (distance) in                            expect(distance).to(equal(expected))
                                        done()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK:- Utility methods
    
    func getDistance(_ locations: [CLLocation]) -> CLLocationDistance {
        var distance : CLLocationDistance = 0.0
        
        var i = 0
        while(i + 1 < locations.count ) {
            log.debug("calc distance from index \(i) to \(i+1)")
            distance += locations[i].distance(from: locations[i+1])
            i += 1
        }
        
        return distance
    }
    
    func generateRandomCoordinates(min: UInt32, max: UInt32)-> CLLocationCoordinate2D {
        //Get the Current Location's longitude and latitude
        let currentLong = -96.80322
        let currentLat = 32.9697
        
        //1 KiloMeter = 0.00900900900901° So, 1 Meter = 0.00900900900901 / 1000
        let meterCord = 0.00900900900901 / 1000
        
        //Generate random Meters between the maximum and minimum Meters
        let randomMeters = UInt(arc4random_uniform(max) + min)
        
        //then Generating Random numbers for different Methods
        let randomPM = arc4random_uniform(6)
        
        //Then we convert the distance in meters to coordinates by Multiplying number of meters with 1 Meter Coordinate
        let metersCordN = meterCord * Double(randomMeters)
        
        //here we generate the last Coordinates
        if randomPM == 0 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 1 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 2 {
            return CLLocationCoordinate2D(latitude: currentLat + metersCordN, longitude: currentLong - metersCordN)
        }else if randomPM == 3 {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong + metersCordN)
        }else if randomPM == 4 {
            return CLLocationCoordinate2D(latitude: currentLat, longitude: currentLong - metersCordN)
        }else {
            return CLLocationCoordinate2D(latitude: currentLat - metersCordN, longitude: currentLong)
        }
    }
}
