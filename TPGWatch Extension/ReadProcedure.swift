//
//  ReadOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit

final class ReadArrayProcedure: Procedure, OutputProcedure {

    var output: Pending<ProcedureResult<[[String: Any]]>> = .pending
    let url: URL

    init(url: URL) {
        self.url = url
        super.init()

        name = "Read operation for \(url.lastPathComponent)"
    }

    override func execute() {

        if let data = NSArray(contentsOf: url) as? [[String: Any]] {
            self.finish(withResult: .success(data))
        } else {
            self.finish(withError: NSError(domain: "", code: 0, userInfo: nil))
        }
    }
}

final class ReadDictionaryOperation: Procedure, OutputProcedure {

    var output: Pending<ProcedureResult<[String: Any]>> = .pending
    let url: URL

    init(url: URL) {
        self.url = url
        super.init()

        name = "Read operation for \(url.lastPathComponent)"
    }

    override func execute() {

        if let data = NSDictionary(contentsOf: url) as? [String: Any] {
            self.finish(withResult: .success(data))
        } else {
            self.finish(withError: NSError(domain: "", code: 0, userInfo: nil))
        }
    }
}
