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

    var input: Pending<Resource<ParsedLineColorRecord>> = .pending
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

        guard let lineColorRecord = self.input.value?.value else {
            self.finish(withError: GeneralError.unexpectedData)
            return
        }


        context.perform {
            for lineColor in lineColorRecord.lineColors {

                let line = NSEntityDescription.insertNewObject(forEntityName: Line.EntityName, into: self.context) as! Line

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
                self.finish(withError: error)
            }
        }

    }


}
