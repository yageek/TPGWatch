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

extension ParsedLineColorRecord: JSONUnmarshable {
    public init?(JSON: [String: Any]) {
        self.init(json: JSON)
    }
}

extension ParsedStopsRecord: JSONUnmarshable {
    public init?(JSON: [String: Any]) {
        self.init(json: JSON)
    }
}

final class GetStopsProcedure: GroupProcedure {

    let completion: (_ inner: () throws -> Void) -> Void

    init(context: NSManagedObjectContext, proxy: WatchProxy?, completion: @escaping (_ inner: () throws -> Void) -> Void) {

        self.completion = completion

        // Line Operations
        let getLinesCall = API.getLinesColors
        let downloadLinesOp = DownloadProcedure(call: getLinesCall)
        let parseLinesOp = JSONDeserializationProcedure<ParsedLineColorRecord>().injectPayload(fromNetwork: downloadLinesOp)
        let importLinesOp = ImportLinesColorsProcedure(context: context).injectResult(from: parseLinesOp)

        // Stops Operations
        let getStopsCall = API.getStops(stopCode: nil, stopName: nil, line: nil, latitude: nil, longitude: nil)
        let downloadStopsOp = DownloadProcedure(call: getStopsCall)
        let parseStopsOp = JSONDeserializationProcedure<ParsedStopsRecord>().injectPayload(fromNetwork: downloadStopsOp)
        let importStopsOp = ImportStopProcedure(context: context).injectResult(from: parseStopsOp)

        // Synchronisation
        importStopsOp.addDependency(importLinesOp)
        importStopsOp.add(condition: NoFailedDependenciesCondition())

        super.init(operations: [])

        name = "Get Stops operations"

        add(condition: MutuallyExclusive<GetStopsProcedure>())
        add(children: [downloadLinesOp, parseLinesOp, importLinesOp, downloadStopsOp, parseStopsOp, importStopsOp])

        if let proxy = proxy {
            let sendRegisteryOp = SendRegisteryProcedure(context: context, proxy: proxy)
            sendRegisteryOp.add(dependency: importStopsOp)
            sendRegisteryOp.add(condition: NoFailedDependenciesCondition())
            add(child: sendRegisteryOp)
        }


        addDidFinishBlockObserver { (_, errors) in
            print("Errors: \(errors)")

            self.completion {
                if let error = errors.first {
                    throw error
                }
            }

        }
    }

}
