//
//  NavTableTests.swift
//  pathsTests
//
//  Created by kfinn on 2/20/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import XCTest
import Quick
import Nimble
import RxSwift
import CoreLocation
import CoreData

@testable import paths

class NavTableViewControllerTests: QuickSpec {
    override func spec(){
        var subject: NavTableViewController!
        
        describe("NavTableViewController"){
            beforeEach {
                subject = NavTableViewController()
            }
            
            describe("initially"){
                it("displays the names of the paths in the database"){
                    
                }
                
                it("orders the paths by date descending"){
                    
                }
                
                it("groups the paths by day"){

                }
            }
            
            describe("when a path row is clicked"){
                it("loads the path in PathManager as the current path"){
                    
                }
                it("launches the PageViewController"){
                    
                }
            }
            
            describe("when the add bar button is clicked"){
                it("launches the 'NewPathViewController'"){}
            }
        }
    }
}
