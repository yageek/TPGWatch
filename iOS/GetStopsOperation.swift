//
//  GetStopsOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Operations
import CoreData
import TPGSwift

final class GetStopsOperation: GroupOperation {

    let completion: (inner: () throws -> Void) -> Void

    init(context: NSManagedObjectContext, completion: (inner: () throws -> Void) -> Void) {

        self.completion = completion

        // Line Operations
        let getLinesCall = API.GetLinesColors
        let downloadLinesOp = DownloadOperation(call: getLinesCall)
        let parseLinesOp = JSONUnmarshalOperation()
        let importLinesOp = ImportLinesColorsOperation(context: context)

        parseLinesOp.injectResultFromDependency(downloadLinesOp)
        importLinesOp.injectResultFromDependency(parseLinesOp)


        // Stops Operations
        let getStopsCall = API.GetStops(stopCode: nil, stopName: nil, line: nil, latitude: nil, longitude: nil)
        let downloadStopsOp = DownloadOperation(call: getStopsCall)
        let parseStopsOp = JSONUnmarshalOperation()
        let importStopsOp = ImportStopOperation(context: context)

        parseStopsOp.injectResultFromDependency(downloadStopsOp)
        importStopsOp.injectResultFromDependency(parseStopsOp)

        // Synchronisation
        importStopsOp.addDependency(importLinesOp)
        importStopsOp.addCondition(NoFailedDependenciesCondition())
        super.init(operations: [])

        name = "Get Stops operations"

        addCondition(MutuallyExclusive<GetStopsOperation>())
        addOperations(downloadLinesOp, parseLinesOp, importLinesOp, downloadStopsOp, parseStopsOp, importStopsOp)
    }

    override func operationDidFinish(errors: [ErrorType]) {
        print("Errors: \(errors)")

        self.completion { 
            if let error = errors.first {
                throw error
            }
        }
    }
}
