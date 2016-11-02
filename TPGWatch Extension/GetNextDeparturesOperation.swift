//
//  GetNextDeparturesOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import ProcedureKit
import TPGSwift

class GetNextDeparturesOperation: GroupProcedure {

    let completion: (ParsedNextDeparturesRecord?, NSError?) -> Void

    init(code: String, completion: @escaping (ParsedNextDeparturesRecord?, NSError?) -> Void) {
        self.completion = completion

        super.init(operations: [])

        let getDeparturesCall = API.GetNextDepartures(stopCode: code, departureCode: nil , linesCode: nil, destinationsCode: nil)
        let downloadDepartures = DownloadOperation(call: getDeparturesCall)
        let parseDepartures = JSONUnmarshalOperation()

        let blockOp = BlockProcedure {

            if let elements = parseDepartures.result as? [String: AnyObject] {
                if let record =  ParsedNextDeparturesRecord(json: elements) {
                    self.completion(record, nil)
                    return
                }
            }

            self.completion(nil, NSError(domain: "", code: 0, userInfo: nil))
        }

        parseDepartures.inject(dependency: downloadDepartures) { (parseProcedure, downloadProcedure, errors) in

            parseProcedure.requirement = downloadProcedure.result
        }

        blockOp.addDependency(parseDepartures)
        //blockOp.addCondition(condition: NoFailedDependenciesCondition())


        add(children: downloadDepartures, parseDepartures, blockOp)
        name = "Watch download stops"
    }

//    override func operationDidFinish(_ errors: [Error]) {
//
//        if let _ = errors.first {
//            self.completion(nil, NSError(domain: "", code: 0, userInfo: nil))
//        }
//
//
//    }

}
