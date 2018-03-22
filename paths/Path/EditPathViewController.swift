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

/**
 Form for editing the current Path
 */
class EditPathViewController : FormViewController {
    static var dateformatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    lazy var saveAlert : UIAlertController = {
        let alert = UIAlertController(title: "Update?", message: "What would you like to do with your Path?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save changes", style: UIAlertActionStyle.default) {[unowned self] _ in self.save()}
        let actionCancel = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel) {[unowned self] _ in
            self.buttonCancelClicked()
        }
        alert.addAction(actionSave)
        alert.addAction(actionCancel)
        
        return alert
    }()
    public var isNewPath : Bool = false
    
    private weak var pathManager : IPathManager? = PathManager.shared
    fileprivate weak var path : IPath?
    private var disposeBag = DisposeBag()
    
    convenience init(pathManager: IPathManager?) {
        self.init()
        self.pathManager = pathManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pathManager?.currentPathObservable?.subscribe(onNext: { [unowned self] path in
            self.path = path
            self.updateForm(with: self.path)
        }).disposed(by: disposeBag)
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClicked)), animated: false)
        
        createForm()
    }
    
    func createForm() {
        form +++ Section("Main") <<< TextRow { row in
                row.title = "Title"
                row.value = path?.title
                row.tag = "title"
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
                row.hidden = Condition(booleanLiteral: !isNewPath)
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
                row.hidden = Condition(booleanLiteral: !isNewPath)
        }
        
            +++ Section("Notes") <<< TextAreaRow { row in
                row.title = "Notes"
                row.value = path?.notes
                row.tag = "notes"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        save()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func updateForm(with path: IPath?) {
        form.rowBy(tag: "title")?.value = path?.title
        form.rowBy(tag: "notes")?.value = path?.notes
        form.rowBy(tag: "locations")?.value = path?.locations
        form.rowBy(tag: "startdate")?.value = path?.startdate
        form.rowBy(tag: "enddate")?.value = path?.enddate
    }
    @objc func saveButtonClicked(){
        save()
        
        if pathManager?.hasNewPath ?? false {
            self.navigationController?.popToRootViewController(animated: true)
        } else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    func save() {
        guard let path = path else {
            return
        }
        
        path.title = form.rowBy(tag: "title")!.value
        path.locations = form.rowBy(tag: "locations")!.value
        path.startdate = form.rowBy(tag: "startdate")!.value
        path.enddate = form.rowBy(tag: "enddate")!.value
        path.notes = form.rowBy(tag: "notes")!.value
        
        //save
        do {
            try pathManager?.updateCurrentPathInCoreData(notify: true)
        } catch {
            log.error(error.localizedDescription)
        }
        
    }
    func buttonCancelClicked() {
        log.debug("dismiss save alert")
        self.dismiss(animated: true, completion: nil)
    }
}
