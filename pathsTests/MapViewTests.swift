//
//  MapViewTests.swift
//  pathsTests
//
//  Created by Kevin Finn on 3/12/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import XCTest
import Quick
import Nimble
import MapKit
import RandomKit

@testable import paths

class MapViewTests : QuickSpec {
    func generateImageAnnotations() -> [ImageAnnotation] {
        var annotations : [ImageAnnotation] = []
        
        for i in 1...Int.random(in: 3...15, using: &Xorshift.default) {
            let annotation = ImageAnnotation()
            annotation.coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees.random(using: &Xorshift.default), longitude: CLLocationDegrees.random(using: &Xorshift.default))
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    func generatePathAnnotations() -> [MKPointAnnotation] {
        var annotations : [MKPointAnnotation] = []
        
        for i in 1...Int.random(in: 3...15, using: &Xorshift.default) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees.random(using: &Xorshift.default), longitude: CLLocationDegrees.random(using: &Xorshift.default))
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    func generateOverlays() -> [MKOverlay] {
        var overlays : [MKOverlay] = []
        
        for i in 1...Int.random(in: 3...15, using: &Xorshift.default) {
            var coords : [CLLocationCoordinate2D] = []
            for j in 1...Int.random(in: 3...15, using: &Xorshift.default) {
                let coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees.random(using: &Xorshift.default), longitude: CLLocationDegrees.random(using: &Xorshift.default))
                coords.append(coordinate)
            }
            
            let polyline = MKPolyline.init(coordinates: coords, count: coords.count)
            overlays.append(polyline)
        }
        
        return overlays
    }
    
    var mockcontext = ContextWrapper()
    override func spec(){
        var mapView : MapView!
        
        beforeEach {
            mapView = MapView()
        }
        describe("mapView"){
            describe("setImageAnnotations"){
                var annotations : [MKAnnotation]!
                beforeEach{
                    annotations = self.generateImageAnnotations()
                    mapView.setImageAnnotations(annotations)
                }
                it("adds path annotations to the map"){
                    expect(mapView.annotations as NSArray).to(contain(annotations as NSArray))
                }
            }
            
            describe("removePathAnnotations"){
                var annotations : [MKAnnotation]!
                beforeEach{
                    annotations = self.generatePathAnnotations()
                    mapView.setImageAnnotations(annotations)
                    mapView.removePathAnnotations()
                }
                it("removes path annotations from the map"){
                    expect(mapView.annotations as NSArray).toNot(contain(annotations as NSArray))
                }
            }
            describe("remove image annotations"){
                var annotations : [MKAnnotation]!
                
                beforeEach{
                    annotations = self.generateImageAnnotations()
                    mapView.addAnnotations(annotations)
                    mapView.removePathAnnotations()
                }
                it("removes the image annotations from the map"){
                    expect(mapView.annotations as NSArray).toNot(contain(annotations as NSArray))
                }
            }
            
            describe("remove overlays"){
                var overlays : [MKOverlay]!
                
                beforeEach{
                    overlays = self.generateOverlays()
                    mapView.addOverlays(overlays)
                    mapView.removeOverlays()
                }
                it("removes all overlays from the map"){
                    expect(mapView.overlays.count).to(equal(0))
                }
            }
            
            describe("load path"){
                var path : Path!
                var points : [CLLocationCoordinate2D]!
                beforeEach {
                    path = PathTools.generateRandomPath()
                    points = path.getPoints()
                    mapView.load(path: path)
                }
                
                it("adds path annotations"){
                    expect(mapView.pathAnnotations.count).to(equal(2))
                    if mapView.pathAnnotations.count == 2 {
                        expect(mapView.pathAnnotations[0].coordinate).toEventually(equal(points.first!))
                        expect(mapView.pathAnnotations[1].coordinate).toEventually(equal(points.last!))
                    }
                }
                
                it("adds path overlay"){
                    expect(mapView.overlays.count).toEventually(equal(1))
                    if mapView.overlays.count > 0 {
                        expect(mapView.overlays[0]).to(beAKindOf(MKPolyline.self))
                    }
                }
            }
            
            describe("taking a snapshot"){
                it("returns an image of the path map"){
                    
                }
            }
            
        }
    }
}
//
//extension Equatable where Self: MKAnnotation {}
//
//func == (lhs: MKAnnotation, rhs: MKAnnotation) -> Bool {
//    return lhs.coordinate == rhs.coordinate && lhs.title! == rhs.title! && lhs.subtitle! == rhs.subtitle!
//}

extension CLLocationCoordinate2D : Equatable{}

public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}


