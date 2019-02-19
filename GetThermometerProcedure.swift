//
//  GetThermometerProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 16.10.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

import ProcedureKit
import TPGSwift

final class GetThermometerProcedure: GroupProcedure {
    init(departureCode: Int, completion: @escaping (Thermometer?, NSError?) -> Void) {

        let getThermometerCall = API.getThermometer(departureCode: "\(departureCode)")
        let downloadDepartures = DownloadProcedure(call: getThermometerCall)
        let parseDepartures = JSONDeserializationProcedure<Thermometer>().injectPayload(fromNetwork: downloadDepartures)
        parseDepartures.addDidFinishBlockObserver { (procedure, error) in

            if let value = procedure.output.success {
                ProcedureQueue.main.addOperation {
                    print("Value: \(value)")
                    completion(value, nil)
                }
            } else {
                print("Some errors occured: \(String(describing: error))")
                ProcedureQueue.main.addOperation {
                    completion(nil, NSError(domain: "", code: 0, userInfo: nil))
                }
            }
        }

        super.init(operations: [downloadDepartures, parseDepartures])
        name = "Download Thermometer Procedure \(departureCode)"
    }
}

