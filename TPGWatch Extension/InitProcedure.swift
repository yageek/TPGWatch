//
//  InitProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit
import WatchKit

class InitProcedure: GroupProcedure {

    init(label: WKInterfaceLabel, root: WKInterfaceController) {

        // Cleaning old files
        let cleanupString = NSLocalizedString("Cleaning...", comment: "Cleanup sentence")
        let cleanupDisplayOp = UpdateDisplayProcedure(label: label, text: cleanupString)

        let cleanUpOp = CleanUpV2Procedure()
        cleanUpOp.addDependency(cleanupDisplayOp)


        // Check presence of files on watch
        let checkString = NSLocalizedString("Checking files...", comment: "Check files")

        let checkFilesDisplayOp = UpdateDisplayProcedure(label: label, text: checkString)
        let checkFilesOp = CheckFilesProcedure()

        checkFilesDisplayOp.addDependency(cleanUpOp)
        checkFilesOp.addDependency(checkFilesDisplayOp)


        let presentScreenOp = PresentFirstScreenProcedure(label: label, rootController: root)

        presentScreenOp.inject(dependency: checkFilesOp) { (presentProcedure, checkFileProcedure, errors) in
            presentProcedure.requirement = checkFilesOp.result
        }

        super.init(operations: [cleanupDisplayOp, cleanUpOp, checkFilesDisplayOp, checkFilesOp, presentScreenOp])
    }
}
