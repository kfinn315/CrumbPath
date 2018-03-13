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

@testable import paths

class MapViewTests : QuickSpec {
    var mockcontext = ContextWrapper()
    override func spec(){
        var mapView : MapView!
        
        beforeEach {
            mapView = MapView()
        }
        describe("mapView"){
            describe("setPathAnnotations"){
                it("adds path annotations to the map"){
                    
                }
            }
            
            describe("removePathAnnotations"){
                it("removes path annotations from the map"){
                    
                }
            }
            describe("remove image annotations"){
                it("removes the image annotations from the map"){
                    
                }
            }
            
            describe("remove overlays"){
                it("removes the overlay line from the map"){
                    
                }
            }
            
            describe("load path"){
                it("sets the map to the given Path"){
                    
                }
                
                it("adds annotations"){
                    
                }
                
                it("adds path overlay"){
                    
                }
                
                it("zooms to the correct height"){
                    
                }
            }
            
            describe("taking a snapshot"){
                it("returns an image of the path map"){
                    
                }
            }
            
        }
    }
}
