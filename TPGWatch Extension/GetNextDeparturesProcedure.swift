//
//  GetNextDeparturesProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import ProcedureKit
import TPGSwift

extension ParsedNextDeparturesRecord: JSONUnmarshable {
    public init?(JSON: [String: Any]) {
        self.init(json: JSON)
    }
}
class GetNextDeparturesProcedure: GroupProcedure {


    init(code: String, completion: @escaping (ParsedNextDeparturesRecord?, NSError?) -> Void) {

        let getDeparturesCall = API.getNextDepartures(stopCode: code, departureCode: nil , linesCode: nil, destinationsCode: nil)
        let downloadDepartures = DownloadProcedure(call: getDeparturesCall)
        let parseDepartures = JSONDeserializationProcedure<ParsedNextDeparturesRecord>().injectPayload(fromNetwork: downloadDepartures)
        parseDepartures.addDidFinishBlockObserver { (procedure, errors) in

            if let value = procedure.output.success {
                ProcedureQueue.main.addOperation {
                    print("Value: \(value)")
                    completion(value.value, nil)
                }
            } else {
                ProcedureQueue.main.addOperation {
                    completion(nil, NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }

        super.init(operations: [downloadDepartures, parseDepartures])
        name = "Watch download stops"
    }
}
