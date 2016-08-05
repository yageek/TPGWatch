//
//  ReadOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations

class ReadOperation: Operation, ResultOperationType {

    var result: [[String: AnyObject]]?
    let url: NSURL

    init(url: NSURL) {
        self.url = url
        super.init()

        name = "Read operation"
    }

    override func execute() {
        if let stops = NSArray(contentsOfURL: url) as? [[String: AnyObject]] {
            result = stops
            finish()

        } else {
            finish(NSError(domain: "", code: 0, userInfo: nil))
        }

    }
}
