//
//  SaveOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations

class SaveOperation: Operation {

    let data: AnyObject?
    let saveURL: NSURL

    init(data: AnyObject, saveURL: NSURL) {
        self.data = data
        self.saveURL = saveURL

        super.init()

        name = "Saving operation"
    }

    override func execute() {
        guard !cancelled else { return }

        var result: Bool = false

        if let array = data as? [[String: AnyObject]] {
            result = (array as NSArray).writeToURL(self.saveURL, atomically: true)
        } else if let dict = data as? [String: AnyObject] {
            result = (dict as NSDictionary).writeToURL(self.saveURL, atomically: true)
        }

        if !result {
            self.finish(NSError(domain: "", code: 0, userInfo: nil))
        } else {
            self.finish()
        }


    }
}
