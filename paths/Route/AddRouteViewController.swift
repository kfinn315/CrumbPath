//
//  AddRouteViewController.swift
//  paths
//
//  Created by Kevin Finn on 3/21/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import Eureka

class AddRouteViewController : FormViewController {
    var route : Route? {
        didSet{
            updateForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveButtonClicked)), animated: false)
        
        createForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if route == nil {
            route = Route(PathManager.managedObjectContext)
        }
    }
    func createForm() {
        form +++ Section("Main") <<< TextRow { row in
            row.title = "Title"
            row.tag = "title"
        }
        
        updateForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        save()
    }
    
    func updateForm() {
        form.rowBy(tag: "title")?.value = route?.title
    }
    @objc func saveButtonClicked(){
        
        self.navigationController?.popViewController(animated: true)
    }
    func save() {
        guard let route = route else {
            return
        }
        
        route.title = form.rowBy(tag: "title")!.value
        
        //save
        do {
            if PathManager.managedObjectContext.updatedObjects.count > 0 {
                try PathManager.managedObjectContext.save()
            }
            PathManager.managedObjectContext.refreshAllObjects()
        } catch {
            log.error(error.localizedDescription)
        }
    }
}
