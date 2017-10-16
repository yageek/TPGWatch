//
//  GetNextDeparturesProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit
import TPGSwift

#if os(iOS)
import ProcedureKitMobile
#endif

final class GetNextDeparturesProcedure: GroupProcedure {
    init(code: String, completion: @escaping (NextDepartureRecord?, NSError?) -> Void) {

        let getDeparturesCall = API.getNextDepartures(stopCode: code, departureCode: nil, linesCode: nil, destinationsCode: nil)
        let downloadDepartures = DownloadProcedure(call: getDeparturesCall)
        let parseDepartures = JSONDeserializationProcedure<NextDepartureRecord>().injectPayload(fromNetwork: downloadDepartures)
        parseDepartures.addDidFinishBlockObserver { (procedure, _) in

            if let value = procedure.output.success {
                ProcedureQueue.main.addOperation {
                    print("Value: \(value)")
                    completion(value, nil)
                }
            } else {
                ProcedureQueue.main.addOperation {
                    completion(nil, NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }

        super.init(operations: [downloadDepartures, parseDepartures])
        name = "Download Stops Procedure \(code)"
    }
}
