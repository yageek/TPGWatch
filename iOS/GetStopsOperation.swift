//
//  GetStopsOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import CoreData
import TPGSwift

final class GetStopsOperation: GroupOperation {

    let completion: (_ inner: () throws -> Void) -> Void

    init(context: NSManagedObjectContext, proxy: WatchProxy?, completion: @escaping (_ inner: () throws -> Void) -> Void) {

        self.completion = completion

        // Line Operations
        let getLinesCall = API.getLinesColors
        let downloadLinesOp = DownloadOperation(call: getLinesCall)
        let parseLinesOp = JSONUnmarshalOperation()
        let importLinesOp = ImportLinesColorsOperation(context: context)

        parseLinesOp.injectResultFromDependency(downloadLinesOp)
        importLinesOp.injectResultFromDependency(parseLinesOp)


        // Stops Operations
        let getStopsCall = API.getStops(stopCode: nil, stopName: nil, line: nil, latitude: nil, longitude: nil)
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
        addOperations([downloadLinesOp, parseLinesOp, importLinesOp, downloadStopsOp, parseStopsOp, importStopsOp])

        if let proxy = proxy {
            let sendRegisteryOp = SendRegisteryOperation(context: context, proxy: proxy)
            sendRegisteryOp.addDependency(importStopsOp)
            sendRegisteryOp.addCondition(NoFailedDependenciesCondition())
            self.addOperation(sendRegisteryOp)
        }
    }

    override func operationDidFinish(_ errors: [Error]) {
        print("Errors: \(errors)")

        self.completion { 
            if let error = errors.first {
                throw error
            }
        }
    }
}
