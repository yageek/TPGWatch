//
//  GetStopsProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import CoreData
import TPGSwift

final class GetStopsProcedure: GroupProcedure {

    let completion: (_ inner: () throws -> Void) -> Void

    init(context: NSManagedObjectContext, proxy: WatchProxy?, completion: @escaping (_ inner: () throws -> Void) -> Void) {

        self.completion = completion

        // Line Operations
        let getLinesCall = API.GetLinesColors
        let downloadLinesOp = DownloadProcedure(call: getLinesCall)
        let parseLinesOp = JSONUnmarshalProcedure()
        let importLinesOp = ImportLinesColorsProcedure(context: context)

        parseLinesOp.injectResultFromDependency(downloadLinesOp)
        importLinesOp.injectResultFromDependency(parseLinesOp)


        // Stops Operations
        let getStopsCall = API.getStops(stopCode: nil, stopName: nil, line: nil, latitude: nil, longitude: nil)
        let downloadStopsOp = DownloadProcedure(call: getStopsCall)
        let parseStopsOp = JSONUnmarshalProcedure()
        let importStopsOp = ImportStopProcedure(context: context)


        parseStopsOp.injectResultFromDependency(downloadStopsOp)
        importStopsOp.injectResultFromDependency(parseStopsOp)

        // Synchronisation
        importStopsOp.addDependency(importLinesOp)
        importStopsOp.addCondition(NoFailedDependenciesCondition())

        super.init(operations: [])

        name = "Get Stops operations"

        addCondition(MutuallyExclusive<GetStopsProcedure>())
        addOperations([downloadLinesOp, parseLinesOp, importLinesOp, downloadStopsOp, parseStopsOp, importStopsOp])

        if let proxy = proxy {
            let sendRegisteryOp = SendRegisteryProcedure(context: context, proxy: proxy)
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
