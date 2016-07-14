//
//  SendToWatchOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 14.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations
import CoreData
import WatchConnectivity

class SendToWatchOperation: Operation {

    let context: NSManagedObjectContext
    let watchProxy: WatchProxy

    init(context: NSManagedObjectContext, proxy: WatchProxy) {

        self.watchProxy = proxy

        let importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.context = context
        super.init()

        name = "Watch synchronisation operation"
    }

    override func execute() {

        // FetchStops
        let request = NSFetchRequest(entityName: Stop.EntityName)
        request.propertiesToFetch = ["code", "name"]
        request.includesSubentities = false

        context.performBlock { 

            do {
                let stops = try self.context.executeFetchRequest(request) as! [Stop]
                self.sendStops(stops)
                self.finish()
                
            } catch let error {
                print("Impossible to fetch stops: \(error)")
                self.finish(error)
            }
        }
    }

    private func sendStops(stops: [Stop]) {

        let stopsJSON = stops.map { (stop) -> [String: AnyObject] in
            return [stop.code!: stop.name!]

        }

        let registery = ["registery": stopsJSON]
        watchProxy.sendStopsRegistery(registery)
    }
}
