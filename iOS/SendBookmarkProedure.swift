//
//  SendBookmarkOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 11.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit
import CoreData

class SendBookmarkOperation: Procedure {
    let context: NSManagedObjectContext
    let watchProxy: WatchProxy

    init(context: NSManagedObjectContext, proxy: WatchProxy) {

        self.watchProxy = proxy

        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.context = context
        super.init()

        name = "Watch bookmark synchronisation operation"
    }
    override func execute() {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Stop.EntityName)
        request.predicate = NSPredicate(format: "bookmarked == true")
        request.propertiesToFetch = ["code", "name"]
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let stopsObjects = try context.fetch(request) as! [Stop]
            let stops = stopsObjects.map({ (stop) -> [String:AnyObject] in

                let connections = (stop.value(forKeyPath: "connections.line.code") as AnyObject).allObjects ?? []

                return [
                    "name" : stop.name! as AnyObject,
                    "code" : stop.code! as AnyObject,
                    "lines": connections as AnyObject,
                ]
            })

            let dict: [String: Any] = ["stops": stops as AnyObject]

            try watchProxy.sendData(dict)
            self.finish()
        } catch let error {
            print("Can not send error:\(error)")
            self.finish(withError: error)
        }
    }

}
