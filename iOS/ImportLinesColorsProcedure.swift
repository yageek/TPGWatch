//
//  ImportLinesColorsProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import CoreData
import TPGSwift
import UIKit

final class ImportLinesColorsProcedure: Procedure, InputProcedure {

    var input: Pending<Record<TPGSwift.LineColor>> = .pending
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

        guard let lineColorRecord = self.input.value else {
            self.finish(withError: GeneralError.unexpectedData)
            return
        }

        context.perform {
            for lineColor in lineColorRecord.elements {

                let line = NSEntityDescription.insertNewObject(forEntityName: Line.EntityName, into: self.context) as! Line
                line.code = lineColor.code
                line.backgroundColor = lineColor.background.hexString
                line.textColor = lineColor.text.hexString
                line.ribonColor = lineColor.hexa.hexString
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
}
