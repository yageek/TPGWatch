//
//  SendRegisteryOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 14.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations
import CoreData
import WatchConnectivity

class SendRegisteryOperation: Operation {

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
        let request = NSFetchRequest(entityName: Line.EntityName)
        request.includesSubentities = false

        context.performBlock { 

            do {
                let lines = try self.context.executeFetchRequest(request) as! [Line]
                self.sendLines(lines)
                self.finish()
                
            } catch let error {
                print("Impossible to fetch stops: \(error)")
                self.finish(error)
            }
        }
    }

    private func sendLines(lines: [Line]) {

        let linesJSON = lines.map { (line) -> [String: AnyObject] in
            return [line.code!:
                [
                    "backgroundColor" : line.backgroundColor!,
                    "textColor" : line.textColor!,
                    "ribonColor" : line.ribonColor!
                ]
            ]

        }

        let registery = ["registery": linesJSON]
        watchProxy.sendLinesRegistery(registery)
    }
}
