//
//  SaveOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit


class SaveOperation: Procedure {

    let data: AnyObject?
    let saveURL: URL

    init(data: AnyObject, saveURL: URL) {
        self.data = data
        self.saveURL = saveURL

        super.init()

        name = "Saving operation"
    }

    override func execute() {
        guard !isCancelled else { return }

        var result: Bool = false

        if let array = data as? [[String: AnyObject]] {
            result = (array as NSArray).write(to: self.saveURL, atomically: true)
        } else if let dict = data as? [String: AnyObject] {
            result = (dict as NSDictionary).write(to: self.saveURL, atomically: true)
        }

        if !result {
            self.finish(withErrors: [GeneralError.unexpectedError])
        } else {
            self.finish()
        }


    }
}
