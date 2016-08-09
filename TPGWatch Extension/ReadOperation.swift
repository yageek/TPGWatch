//
//  ReadOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations

class ReadArrayOperation: Operation, ResultOperationType {

    var result: [[String: AnyObject]]?
    let url: NSURL

    init(url: NSURL) {
        self.url = url
        super.init()

        name = "Read operation for \(url.lastPathComponent)"
    }

    override func execute() {

        if let data = NSArray(contentsOfURL: url) as? [[String: AnyObject]]{
            result = data
            self.finish()
        } else {
            self.finish(NSError(domain: "", code: 0, userInfo: nil))
        }
    }
}

class ReadDictionaryOperation: Operation, ResultOperationType {

    var result: [String: AnyObject]?
    let url: NSURL

    init(url: NSURL) {
        self.url = url
        super.init()

        name = "Read operation for \(url.lastPathComponent)"
    }

    override func execute() {

        if let data = NSDictionary(contentsOfURL: url) as? [String: AnyObject]{
            result = data
            self.finish()
        } else {
            self.finish(NSError(domain: "", code: 0, userInfo: nil))
        }
    }
}
