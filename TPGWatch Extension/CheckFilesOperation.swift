//
//  CheckFilesOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import ProcedureKit

open class CheckFilesOperation: Procedure {

    public typealias Result = (hasBookmark: Bool, hasregistery: Bool)?

    open var result: (hasBookmark: Bool, hasregistery: Bool)?

    override open func execute() {

        let fileManager = FileManager.default

        let bookmark = fileManager.fileExists(atPath: Store.StopsFileURL.path)
        let registery = fileManager.fileExists(atPath: Store.RegisteryFileURL.path)

        result = (hasBookmark: bookmark, hasregistery: registery)

        self.finish()
    }
}
