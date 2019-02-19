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
#if os(iOS)
    import ProcedureKitMobile
#endif

final class ValidAPICodeProcedure<T: Equatable>: Procedure, InputProcedure, OutputProcedure {

    var input: Pending<HTTPPayloadResponse<T>> = .pending
    var output: Pending<ProcedureResult<HTTPPayloadResponse<T>>> = .pending

    override func execute() {
        guard let input = input.value else {
            self.finish(with: ProcedureKitError.requirementNotSatisfied())
            return
        }

        switch input.response.statusCode {
        case 200..<299:
            print("OK - Status: \(input.response.statusCode)")
            self.output = .ready(.success(input))
            self.finish()
        default:
            print("ERROR - Status: \(input.response.statusCode)")
            print("ERROR - Content: \(String(describing: input.payload))")
            self.output = .ready(.failure(GeneralError.apiError))
            finish(with: GeneralError.apiError)
        }
    }
}

final class DownloadProcedure: GroupProcedure, OutputProcedure {

    var output: Pending<ProcedureResult<HTTPPayloadResponse<URL>>> = .pending

    init(call: API) {

        let URL = call.URL
        #if DEBUG
            print("URL: \(URL)")
        #endif
        let network = NetworkDownloadProcedure(session: URLSession.shared, request: URLRequest(url: URL))
        let decode = ValidAPICodeProcedure().injectResult(from: network)

        super.init(operations: [network, decode])

        decode.addDidFinishBlockObserver { [weak self](procedure, _)  in
            self?.output = procedure.output
        }

        #if os(iOS)
        decode.addObserver(NetworkObserver(controller: NetworkActivityController()))
        #endif
    }

}
