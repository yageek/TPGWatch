//
//  DownloadOperation.swift
//  GenevaNextBus
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations
import TPGSwift

final class DownloadOperation: GroupOperation, ResultOperationType {

    private(set) var result: NSURL?

    init(call: API) {
        super.init(operations: [])

        guard !cancelled else { return }

        let downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(call.URL) { (tempURL, response, error) in

            self.didDownloadData(tempURL, response: response as? NSHTTPURLResponse, error: error)
        }

        let downloadOperation = URLSessionTaskOperation(task: downloadTask)
        let reachabilityCondition = ReachabilityCondition(url: call.URL)
        let observer = NetworkObserver()

        downloadOperation.addCondition(reachabilityCondition)
        downloadOperation.addObserver(observer)

        self.addOperation(downloadOperation)
    }

    internal func didDownloadData(file: NSURL?, response: NSHTTPURLResponse?, error: NSError?) {

        if let error = error {
            self.finish(error)
            return
        } else {
            result = file
        }


    }

}
