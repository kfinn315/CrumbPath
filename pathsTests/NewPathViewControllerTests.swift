//
//  NewPathViewControllerTests.swift
//  pathsTests
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RxSwift
import CoreLocation

@testable import paths

class NewPathViewControllerTests: QuickSpec {
    override func spec(){
        var subject: NewPathViewController!

        describe("NewPathViewController"){
            describe("When the app is not authorized to use location services"){
                it("shows a message directing the user to change the settings"){
                }
                
                it("disables the 'start' button"){
                }
                
                it("disables the quality option bar"){
                    
                }
            }
            
            describe("when the app is authorized to use location services"){
                it("enables the 'start' button"){
                    
                }
                
                it("shows instruction message")
                {}
            }
            
            describe("When the app does not have a location permission set"){
                it("presents the permission dialog"){}
            }
            
            describe("When the 'start' button is pressed"){
                it("shows the Recording view controller"){}
            }
        }
    }
}

