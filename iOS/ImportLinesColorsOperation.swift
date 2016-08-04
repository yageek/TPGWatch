//
//  ImportLinesColorsOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Operations
import CoreData
import TPGSwift
import UIKit

final class ImportLinesColorsOperation: Operation, AutomaticInjectionOperationType {

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
        
        guard let lineColorRecordJSON = self.requirement as? [String:AnyObject] else {
            self.finish(Error.InvalidData)
            return
        }

        guard let lineColorRecord = ParsedLineColorRecord(json: lineColorRecordJSON) else {
            self.finish(Error.InvalidData)
            return
        }

        context.performBlock {
            for lineColor in lineColorRecord.lineColors {

                let line = NSEntityDescription.insertNewObjectForEntityForName(Line.EntityName, inManagedObjectContext: self.context) as! Line

                line.code = lineColor.lineCode
                line.backgroundColor = "#\(lineColor.background)"
                line.textColor = "#\(lineColor.text)"
                line.ribonColor = "#\(lineColor.hexa)"
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


}
