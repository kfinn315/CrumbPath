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
        var window : UIWindow!
        var contextWrapper : ContextWrapper!
        var datasource : UITableViewDataSource!
        var tableview : UITableView!

        describe("NavTableViewController"){
            beforeEach {
                window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                subject = storyboard.instantiateViewController(withIdentifier: NavTableViewController.storyboardID) as! NavTableViewController
                window.makeKeyAndVisible()
                window.rootViewController = subject
                
                contextWrapper = ContextWrapper()
                subject.managedObjectContext = contextWrapper.context
                
                tableview = subject.tableView
                datasource = subject.tableView.dataSource
                
                // Act:
                subject.beginAppearanceTransition(true, animated: false) // Triggers viewWillAppear
                subject.endAppearanceTransition() // Triggers viewDidAppear
            }
            
            describe("viewDidAppear"){
                beforeEach{
                }
                it("displays all the paths in the table"){
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
