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

    let completion: (ParsedNextDeparturesRecord?, NSError?) -> Void

    init(code: String, completion: @escaping (ParsedNextDeparturesRecord?, NSError?) -> Void) {
        self.completion = completion
        let getDeparturesCall = API.GetNextDepartures(stopCode: code, departureCode: nil , linesCode: nil, destinationsCode: nil)
        let downloadDepartures = DownloadProcedure(call: getDeparturesCall)
        let parseDepartures = JSONDeserializationProcedure<ParsedNextDeparturesRecord>().injectPayload(fromNetwork: downloadDepartures)

        super.init(operations: [downloadDepartures, parseDepartures])
        name = "Watch download stops"
    }
}
