//
//  CleanUpV2Operation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import ProcedureKit

/**
 Cleanup Old V2 storage file.
 */
class CleanUpV2Operation: GroupProcedure {

    init() {


        let bookOp = DeleteFileOperation(url: Store.StopsFileURL.deletingPathExtension().appendingPathExtension("json"))
        let registeryOp = DeleteFileOperation(url:  Store.RegisteryFileURL.deletingPathExtension().appendingPathExtension("json"))

        super.init(operations: [bookOp, registeryOp])

        name = "Clean Up Old file operation"
    }
}

class DeleteFileOperation: Procedure{

    let url: URL

    init(url: URL) {
        self.url = url
        super.init()

        name = "Delete file \(url.lastPathComponent) operation"
    }

    override func execute() {

        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: url.path) else {
            print("Nothing to delete at \(url). Finish...")
            self.finish()
            return
        }

        do {
            print("Deleting file at: \(url)")
            try fileManager.removeItem(at: url)
        } catch let error {
            print("Can not delete file at path: \(error)")
            self.finish(withError: error)
        }
        self.finish()
    }
}
