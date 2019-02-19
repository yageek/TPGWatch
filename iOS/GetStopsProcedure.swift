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

    init(context: NSManagedObjectContext, proxy: WatchProxy, completion: @escaping (_ inner: () throws -> Void) -> Void) {

        self.completion = completion

        // Line Operations
        let getLinesCall = API.getLinesColors
        let downloadLinesOp = DownloadProcedure(call: getLinesCall)
        let parseLinesOp = JSONDeserializationProcedure<Record<TPGSwift.LineColor>>().injectPayload(fromNetwork: downloadLinesOp)
        let importLinesOp = ImportLinesColorsProcedure(context: context).injectResult(from: parseLinesOp)

        // Stops Operations
        let getStopsCall = API.getStops(stopCode: nil, stopName: nil, line: nil, latitude: nil, longitude: nil)
        let downloadStopsOp = DownloadProcedure(call: getStopsCall)
        let parseStopsOp = JSONDeserializationProcedure<Record<TPGSwift.Stop>>().injectPayload(fromNetwork: downloadStopsOp)
        let importStopsOp = ImportStopProcedure(context: context).injectResult(from: parseStopsOp)

        // Synchronisation
        importStopsOp.addDependency(importLinesOp)
        importStopsOp.addCondition(NoFailedDependenciesCondition())

        var operations = [downloadLinesOp, parseLinesOp, importLinesOp, downloadStopsOp, parseStopsOp, importStopsOp]
        if WatchProxy.isWatchSupported {
            let sendRegisteryOp = SendRegisteryProcedure(context: context, proxy: proxy)
            sendRegisteryOp.addDependency(importStopsOp)
            sendRegisteryOp.addCondition(NoFailedDependenciesCondition())
            operations.append(sendRegisteryOp)
        }

        super.init(operations: operations)
        addCondition(MutuallyExclusive<GetStopsProcedure>())
        name = "Get Stops operations"

        addDidFinishBlockObserver { (_, errors) in
            print("Errors: \(String(describing: errors))")

            self.completion {
                if let error = errors {
                    throw error
                }
            }

        }
    }

}
