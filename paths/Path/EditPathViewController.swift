//
//  EditFieldViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/23/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Eureka
import RxCocoa
import RxSwift

class EditPathViewController : FormViewController {
    static var dateformatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    public var isNewPath : Bool = false
    
    private weak var pathManager : IPathManager? = PathManager.shared
    fileprivate weak var path : Path?
    private var disposeBag = DisposeBag()

    convenience init(pathManager: IPathManager?) {
        self.init()
        self.pathManager = pathManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pathManager?.currentPathDriver?.drive(onNext: { [unowned self] path in
            self.path = path
            self.updateData()
        }).disposed(by: disposeBag)
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(save)), animated: false)

        createForm()
    }

    func createForm() {
        form +++ Section("Main") <<< TextRow { row in
            row.title = "Title"
            row.value = path?.title
            row.tag = "title"
            } <<< TextRow { row in
                row.title = "Notes"
                row.value = path?.notes
                row.tag = "notes"
            } <<< TextRow { row in
                row.title = "Locations"
                row.value = path?.locations
                row.tag = "locations"
                row.disabled = Condition(booleanLiteral: isNewPath)
            } <<< DateTimeRow { row in
                row.title = "Start Date and Time"
                row.value = path?.startdate as Date!
                row.dateFormatter = EditPathViewController.dateformatter
                row.maximumDate = path?.enddate as Date!
                row.tag = "startdate"
                row.cellUpdate({ (_, row) in
                    if let enddate = self.form.rowBy(tag: "enddate") as? DateTimeRow {
                        enddate.minimumDate = row.value
                    }
                })
                row.disabled = Condition(booleanLiteral: isNewPath)
            } <<< DateTimeRow { row in
                row.title = "End Date and Time"
                row.value = path?.enddate as Date!
                row.dateFormatter = EditPathViewController.dateformatter
                row.minimumDate = path?.startdate as Date!
                row.tag = "enddate"
                row.cellUpdate({ (_, row) in
                    if let startdate = self.form.rowBy(tag: "startdate") as? DateTimeRow {
                        startdate.maximumDate = row.value
                    }
                })
                row.disabled = Condition(booleanLiteral: isNewPath)
        }        
    }
    
    func updateData() {
        
        for row in form.allRows {
            if let tag = row.tag {
                switch tag {
                case "title": (row as? TextRow)?.value = path?.title
                case "notes": (row as? TextRow)?.value = path?.notes
                case "locations": (row as? TextRow)?.value = path?.locations
                case "startdate" : (row as? DateTimeRow)?.value = path?.startdate as Date?
                case "enddate" : (row as? DateTimeRow)?.value = path?.enddate as Date?
                default:
                    break
                }
            }
        }
    }
    
    @objc func save() {
        guard path != nil else {
            return
        }
        
        for row in form.allRows {
            if let tag = row.tag {
                switch tag {
                case "title":
                    path?.title = (row as? TextRow)!.value
                case "notes":
                    path?.notes = (row as? TextRow)!.value
                case "locations":
                    if !isNewPath {
                        path?.locations = (row as? TextRow)!.value
                    }
                case "startdate" :
                    if !isNewPath {
                        path?.startdate = (row as? DateTimeRow)!.value
                    }
                case "enddate" :
                    if !isNewPath {
                        path?.enddate = (row as? DateTimeRow)!.value
                    }
                default:
                    break
                }
            }
        }
        
        do {
            try pathManager?.updateCurrentPathInCoreData(notify: false)
        } catch {
            log.error(error.localizedDescription)
        }
        
        if pathManager?.hasNewPath ?? false {
            self.navigationController?.popToRootViewController(animated: true)
        } else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
