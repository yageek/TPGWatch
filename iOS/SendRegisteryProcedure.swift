//
//  SendRegisteryProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 14.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit
import CoreData
import WatchConnectivity

final class SendRegisteryProcedure: Procedure {

    let context: NSManagedObjectContext
    let watchProxy: WatchProxy

    init(context: NSManagedObjectContext, proxy: WatchProxy) {

        self.watchProxy = proxy

        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        self.context = context
        super.init()

        name = "Watch synchronisation operation"
    }

    override func execute() {

        // FetchStops
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Line.EntityName)
        request.includesSubentities = false
        context.perform {

            var lines: [Line] = []
            do {
                lines = try self.context.fetch(request) as! [Line]
            } catch let error {
                print("Impossible to fetch stops: \(error)")
                self.finish(withError: error)
            }

            do {
                try self.sendLines(lines)
            } catch let error {
                print("WARN - App watch is not connected: \(error)")
                self.finish(withError: error)
            }
        }
    }

    fileprivate func sendLines(_ lines: [Line]) throws {
        guard !self.isCancelled else { self.finish(); return }

        defer {
            self.finish()
        }

        var linesJSON: [String: Any] = [:]

        for line in lines {
            linesJSON[line.code] =   [
                "backgroundColor": line.backgroundColor,
                "textColor": line.textColor,
                "ribonColor": line.ribonColor
            ]
        }

        guard !linesJSON.isEmpty else {
            print("Registery is empty")
            return
        }

        let registery = ["registery": linesJSON]
        try watchProxy.sendData(registery)
    }
}
