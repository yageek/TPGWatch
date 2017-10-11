//
//  SaveProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit

class SaveProcedure: Procedure {

    let data: Any?
    let saveURL: URL

    init(data: Any, saveURL: URL) {
        self.data = data
        self.saveURL = saveURL

        super.init()

        name = "Saving operation"
    }

    override func execute() {
        guard !isCancelled else { self.finish(); return }

        var result: Bool = false

        if let array = data as? [[String: Any]] {
            result = (array as NSArray).write(to: self.saveURL, atomically: true)
        } else if let dict = data as? [String: Any] {
            result = (dict as NSDictionary).write(to: self.saveURL, atomically: true)
        }

        if !result {
            self.finish(withErrors: [GeneralError.unexpectedError])
        } else {
            self.finish()
        }
    }
}
