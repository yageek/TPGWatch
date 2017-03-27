//
//  ReadOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit

class ReadArrayProcedure: Procedure {

    var result: [[String: Any]]?
    let url: URL

    init(url: URL) {
        self.url = url
        super.init()

        name = "Read operation for \(url.lastPathComponent)"
    }

    override func execute() {

        if let data = NSArray(contentsOf: url) as? [[String: Any]]{
            result = data
            self.finish()
        } else {
            self.finish(withError: NSError(domain: "", code: 0, userInfo: nil))
        }
    }
}

class ReadDictionaryOperation: Procedure {

    var result: [String: Any]?
    let url: URL

    init(url: URL) {
        self.url = url
        super.init()

        name = "Read operation for \(url.lastPathComponent)"
    }

    override func execute() {

        if let data = NSDictionary(contentsOf: url) as? [String: Any]{
            result = data
            self.finish()
        } else {
            self.finish(withError: NSError(domain: "", code: 0, userInfo: nil))
        }
    }
}
