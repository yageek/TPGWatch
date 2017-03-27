//
//  ImportStopProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import CoreData
import TPGSwift

final class ImportStopProcedure: Procedure, InputProcedure {

    var input: Pending<Resource<ParsedStopsRecord>> = .pending
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {

        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        importContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        self.context = importContext
        super.init()

        name = "Import Stop operations"
    }


    override func execute() {

        guard !isCancelled else { self.finish(); return }

        guard case let .ready(requirement) = self.input, let stopRecordJSON = requirement as? [String: Any] else {
            self.finish(withError: GeneralError.unexpectedData)
            return
        }

        guard let  stopRecord = ParsedStopsRecord(json: stopRecordJSON) else {
            self.finish(withError: GeneralError.unexpectedData)
            return
        }

        context.perform { 

            for stopJSON in stopRecord.stops {

                let stop = NSEntityDescription.insertNewObject(forEntityName: Stop.EntityName, into: self.context) as! Stop

                stop.name = stopJSON.name
                stop.code = stopJSON.code
                stop.bookmarked = false

                var connections:[Connection] = []

                for jsonConnection in stopJSON.connections {

                    let CDConnection = NSEntityDescription.insertNewObject(forEntityName: Connection.EntityName, into: self.context) as! Connection

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
                self.finish(withError: error)
            }
        }

    }

    fileprivate func lineForCode(_ lineCode:String) -> Line? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Line.EntityName)
        request.predicate = NSPredicate(format: "code == %@", lineCode)
        request.fetchLimit = 1
        request.includesSubentities = false

        let lines = try? context.fetch(request) as! [Line]
        return lines?.first
    }

}
