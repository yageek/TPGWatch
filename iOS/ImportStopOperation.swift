//
//  ImportStopOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Operations
import CoreData
import TPGSwift

final class ImportStopOperation: Operation, AutomaticInjectionOperationType {

    var requirement: AnyObject?
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {

        let importContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        importContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        self.context = importContext
        super.init()

        name = "Import Stop operations"
    }


    override func execute() {

        guard !cancelled else { return }

        guard let stopRecordJSON = self.requirement as? [String:AnyObject] else {
            self.finish(GeneralError.UnexpectedData)
            return
        }

        guard let  stopRecord = ParsedStopsRecord(json: stopRecordJSON) else {
            self.finish(GeneralError.UnexpectedData)
            return
        }

        context.performBlock { 

            for stopJSON in stopRecord.stops {

                let stop = NSEntityDescription.insertNewObjectForEntityForName(Stop.EntityName, inManagedObjectContext: self.context) as! Stop

                stop.name = stopJSON.name
                stop.code = stopJSON.code
                stop.bookmarked = false

                var connections:[Connection] = []

                for jsonConnection in stopJSON.connections {

                    let CDConnection = NSEntityDescription.insertNewObjectForEntityForName(Connection.EntityName, inManagedObjectContext: self.context) as! Connection

                    CDConnection.destinationCode = jsonConnection.destinationCode
                    CDConnection.destinationName = jsonConnection.destinationName
                    CDConnection.line = self.lineForCode(jsonConnection.lineCode)

                    connections.append(CDConnection)
                }
                stop.connections = NSSet(array: connections)
            }

            do {
                try self.context.save()
                self.finish()
            } catch let error as NSError {
                print("Error during saving:\(error)")
                self.finish(error)
            }
        }

    }

    private func lineForCode(lineCode:String) -> Line? {

        let request = NSFetchRequest(entityName: Line.EntityName)
        request.predicate = NSPredicate(format: "code == %@", lineCode)
        request.fetchLimit = 1
        request.includesSubentities = false

        let lines = try? context.executeFetchRequest(request) as! [Line]
        return lines?.first
    }

}
