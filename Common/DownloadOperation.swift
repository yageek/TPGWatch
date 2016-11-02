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

final class DownloadOperation: GroupProcedure {

    var result: URL?

    init(call: API) {
        super.init(operations: [])

        let downloadTask = URLSession.shared.downloadTask(with: call.URL) { (tempURL, response, error) in

           // self.didDownloadData(tempURL, response: response, error: error)
        }

        let downloadOperation = NetworkDataProcedure(session: URLSession.shared)


        #if os(iOS)
        let reachabilityCondition = ReachabilityCondition(url: call.URL)
        let observer = NetworkObserver()

        downloadOperation.addCondition(reachabilityCondition)
        downloadOperation.addObserver(observer)
        #endif

        self.add(child: downloadOperation)
    }

    internal func didDownloadData(_ file: URL?, response: URLResponse?, error: NSError?) {

        guard let response = response as? HTTPURLResponse else { self.finish(withError: GeneralError.unexpectedError); return }

        if let error = error {
            self.finish(withError: error)
            return
        } else {

            switch response.statusCode {
            case 200:
                result = file
                self.finish()
            case 503:
                self.finish(withError: GeneralError.serviceUnavailable)
            default:
                self.finish(withError: GeneralError.unexpectedError)
            }

        }
    }

}
