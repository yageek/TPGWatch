//
//  PresentFirstScreenProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import ProcedureKit

class PresentFirstScreenProcedure: Procedure {
    let label: WKInterfaceLabel
    var requirement: CheckFilesProcedure.Result
    let rootController: WKInterfaceController

    init(label: WKInterfaceLabel, rootController: WKInterfaceController) {
        self.label = label
        self.rootController = rootController

        super.init()

        name = "Present First Screen operation"
    }

    override func execute() {

        guard let req = requirement else {
            finish(withError: NSError(domain: "", code: 0, userInfo: nil))
            return
        }

        defer {
            self.finish()
        }

        if !req.hasregistery || !req.hasBookmark {

            let text = NSLocalizedString("Open the phone app to sync data", comment: "")
            label.setText(text)

        } else {
            WKInterfaceController.reloadRootControllers(withNames: ["BookmarkStopInterfaceController"], contexts: [])
        }

    }
}
