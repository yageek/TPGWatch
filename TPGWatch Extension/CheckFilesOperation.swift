//
//  CheckFilesOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import Operations

public class CheckFilesOperation: Operation, ResultOperationType {

    public typealias Result = (hasBookmark: Bool, hasregistery: Bool)?

    public var result: (hasBookmark: Bool, hasregistery: Bool)?

    override public func execute() {

        let fileManager = NSFileManager.defaultManager()

        let bookmark = fileManager.fileExistsAtPath(Store.StopsFileURL.path!)
        let registery = fileManager.fileExistsAtPath(Store.RegisteryFileURL.path!)

        result = (hasBookmark: bookmark, hasregistery: registery)

        self.finish()
    }
}
