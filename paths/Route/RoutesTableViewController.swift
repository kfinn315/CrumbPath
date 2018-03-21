//
//  RoutesTableViewController.swift
//  paths
//
//  Created by Kevin Finn on 3/20/18.
//  Copyright © 2018 bingcrowsby. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift
import RxCocoa
import RxCoreData

/**
 UITableView showing the Routes in CoreData
 */
class RouteTableViewController: UITableViewController {
    public static let storyboardID = "Route Table"
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    weak var pathManager = PathManager.shared
    let disposeBag = DisposeBag()
    
    public var onEndUpdates : (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Routes"
        
        tableView.dataSource = nil
        configureTableView()
        
        self.navigationItem.setRightBarButton(UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(addRoute)), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    @objc func addRoute(){
        navigationController?.pushViewController(AddRouteViewController(), animated: true)
    }
    
    func configureTableView() {
        log.info("configure nav table")
        
        let items : Observable<[Route]> =  PathManager.managedObjectContext.rx.entities(Route.self, sortDescriptors: [NSSortDescriptor(key: "title", ascending: false)]).asObservable()
        
        items.bind(to: tableView.rx.items(cellIdentifier: "routecell")) { index, model, cell in cell.textLabel?.text = model.title
            }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map { [unowned self] indexPath -> Route in
            return try self.tableView.rx.model(at: indexPath)
            }.subscribe(onNext: { [unowned self] route in
                let vc = AddRouteViewController()
                vc.route = route
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.map { [unowned self] indexPath -> Route in
            return try self.tableView.rx.model(at: indexPath)
            }.subscribe(onNext: { (route) in
                log.info("delete \(route.localid ?? "nil")")
                //add delete confirmation alert
                do {
                    try PathManager.managedObjectContext.rx.delete(route)
                } catch {
                    log.error(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
