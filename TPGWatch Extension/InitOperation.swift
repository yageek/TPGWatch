//
//  InitOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations
import WatchKit

class InitOperation: GroupOperation {

    init(label: WKInterfaceLabel, root: WKInterfaceController) {

        // Cleaning old files
        let cleanupString = NSLocalizedString("Cleaning...", comment: "Cleanup sentence")
        let cleanupDisplayOp = UpdateDisplayOperation(label: label, text: cleanupString)

        let cleanUpOp = CleanUpV2Operation()
        cleanUpOp.addDependency(cleanupDisplayOp)


        // Check presence of files on watch
        let checkString = NSLocalizedString("Check files...", comment: "Check files")

        let checkFilesDisplayOp = UpdateDisplayOperation(label: label, text: checkString)
        let checkFilesOp = CheckFilesOperation()

        checkFilesDisplayOp.addDependency(cleanUpOp)
        checkFilesOp.addDependency(checkFilesDisplayOp)


        let presentScreenOp = PresentFirstScreenOperation(label: label, rootController: root)

        presentScreenOp.injectResultFromDependency(checkFilesOp)
        super.init(operations: [cleanupDisplayOp, cleanUpOp, checkFilesDisplayOp, checkFilesOp, presentScreenOp])
    }
}
