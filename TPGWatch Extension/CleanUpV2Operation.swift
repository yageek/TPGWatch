//
//  CleanUpV2Operation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import Operations

/**
 Cleanup Old V2 storage file.
 */
class CleanUpV2Operation: GroupOperation {

    init() {


        let bookOp = DeleteFileOperation(url: Store.StopsFileURL.URLByDeletingPathExtension!.URLByAppendingPathExtension("json"))
        let registeryOp = DeleteFileOperation(url:  Store.RegisteryFileURL.URLByDeletingPathExtension!.URLByAppendingPathExtension("json"))

        super.init(operations: [bookOp, registeryOp])

        name = "Clean Up Old file operation"
    }
}

class DeleteFileOperation: Operation {

    let url: NSURL

    init(url: NSURL) {
        self.url = url
        super.init()

        name = "Delete file \(url.lastPathComponent) operation"
    }

    override func execute() {

        let fileManager = NSFileManager.defaultManager()

        guard fileManager.fileExistsAtPath(url.path!) else {
            print("Nothing to delete at \(url). Finish...")
            self.finish()
            return
        }

        do {
            print("Deleting file at: \(url)")
            try fileManager.removeItemAtURL(url)
        } catch let error {
            print("Can not delete file at path: \(error)")
            self.finish(error)
        }
        self.finish()
    }
}
