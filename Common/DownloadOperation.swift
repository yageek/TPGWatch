//
//  DownloadOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Operations
import TPGSwift

final class DownloadOperation: GroupOperation, ResultOperationType {

    private(set) var result: NSURL?

    init(call: API) {
        super.init(operations: [])

        let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(call.URL) { (tempURL, response, error) in

            self.didDownloadData(tempURL, response: response as? NSHTTPURLResponse, error: error)
        }

        let downloadOperation = URLSessionTaskOperation(task: downloadTask)


        #if os(iOS)
        let reachabilityCondition = ReachabilityCondition(url: call.URL)
        let observer = NetworkObserver()

        downloadOperation.addCondition(reachabilityCondition)
        downloadOperation.addObserver(observer)
        #endif

        self.addOperation(downloadOperation)
    }

    internal func didDownloadData(file: NSURL?, response: NSHTTPURLResponse?, error: NSError?) {

        if let error = error {
            self.finish(error)
            return
        } else if let response = response {

            switch response.statusCode {
            case 200:
                result = file
                self.finish()
            case 503:
                self.finish(GeneralError.ServiceUnavailable)
            default:
                self.finish(GeneralError.UnexpectedError)
            }

        }
    }

}