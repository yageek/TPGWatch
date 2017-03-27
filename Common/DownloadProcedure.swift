//
//  DownloadOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import ProcedureKitNetwork
import TPGSwift

class ValidAPICodeProcedure<T: Equatable>: Procedure, InputProcedure, OutputProcedure {

    var input: Pending<HTTPPayloadResponse<T>> = .pending
    var output: Pending<ProcedureResult<HTTPPayloadResponse<T>>> = .pending

    override func execute() {

        guard !isCancelled else { self.finish(); return }

        guard let input = input.value else {
            self.finish(withError: ProcedureKitError.requirementNotSatisfied())
            return
        }

        switch input.response.statusCode {
        case 200..<299:
            print("OK - Status: \(input.response.statusCode)")
            self.output = .ready(.success(input))
            self.finish()
        default:
            print("ERROR - Status: \(input.response.statusCode)")
            print("ERROR - Content: \(input.payload)")
            self.output = .ready(.failure(GeneralError.apiError))
            finish(withError: GeneralError.apiError)
        }
        
    }
}

final class DownloadProcedure: GroupProcedure, OutputProcedure {

    var output: Pending<ProcedureResult<HTTPPayloadResponse<URL>>> = .pending
    init(call: API) {

        let network = NetworkDownloadProcedure(session: URLSession.shared, request: URLRequest(url: call.URL))
        let decode = ValidAPICodeProcedure().injectResult(from: network)

//
//        #if os(iOS)
//        let reachabilityCondition = ReachabilityCondition(url: call.URL)
//        let observer = NetworkObserver()
//
//        downloadOperation.addCondition(reachabilityCondition)
//        downloadOperation.addObserver(observer)
//        #endif
//
//        self.add(child: downloadOperation)

        super.init(operations: [network, decode])

        decode.addDidFinishBlockObserver { [unowned self](procedure, _)  in
            self.output = procedure.output
        }
    }

}
