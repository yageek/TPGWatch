//
//  SendBookmarkOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 11.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations
import CoreData

class SendBookmarkOperation: Operation {
    let context: NSManagedObjectContext
    let watchProxy: WatchProxy

    init(context: NSManagedObjectContext, proxy: WatchProxy) {

        self.watchProxy = proxy

        let importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.context = context
        super.init()

        name = "Watch bookmark synchronisation operation"
    }
    override func execute() {

        let request = NSFetchRequest(entityName: Stop.EntityName)
        request.predicate = NSPredicate(format: "bookmarked == true")
        request.propertiesToFetch = ["code", "name"]
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let stopsObjects = try context.executeFetchRequest(request) as! [Stop]
            let stops = stopsObjects.map({ (stop) -> [String:AnyObject] in

                let connections = stop.valueForKeyPath("connections.line.code")?.allObjects ?? []

                return [
                    "name" : stop.name!,
                    "code" : stop.code!,
                    "lines": connections,
                ]
            })

            let dict: [String: AnyObject] = ["stops": stops]

            try watchProxy.sendData(dict)
            self.finish()
        } catch let error {
            print("Can not send error:\(error)")
            self.finish(error)
        }
    }

}
