////
////  LocationManagerTests.swift
////  pathsTests
////
////  Created by kfinn on 2/20/18.
////  Copyright © 2018 Kevin Finn. All rights reserved.
////
//
//
//import XCTest
//import Quick
//import Nimble
//import RxSwift
//import CoreLocation
//
//@testable import paths
//
//class LocationManagerTests: QuickSpec {
//    override func spec(){
//        var subject: LocationManager!
////
////        describe("LocationManager"){
////            beforeEach {
////                subject = LocationManager()
////            }
////
////            describe("requesting permission"){
////                it("shows the location permission request dialog"){
////
////                }
////            }
////
////            describe("start location updates"){
////                if("has permission"){
////                    expect(CLLocationManager.authorizationStatus()).to(be(CLAuthorizationStatus.authorizedAlways)).or(be(CLAuthorizationStatus.authorizedWhenInUse))
////                }
////                it("starts sending locations"){
////
////                }
////
////                it("says it is updating locations"){
////                    expect(subject.isUpdating).to(beTrue())
////                }
////            }
////
////            describe("start updating location with driving accuracy"){
////                beforeEach{
////                    subject.startLocationUpdates(with: .driving)
////                }
////
////                it("changes accuracy property to 'driving'"){
////                    expect(subject.accuracy).to(be(LocationAccuracy.driving))
////                }
////            }
////
////            describe("stop location updates"){
////                it("stops sending locations"){
////
////                }
////
////                it("says it is not updating locations"){
////                    expect(subject.isUpdating).to(beFalse())
////                }
////            }
////
//
////        }
//    }
//}
//
//
