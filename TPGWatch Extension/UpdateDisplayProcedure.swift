//
//  UpdateDisplayProcedure.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import ProcedureKit
import WatchKit

class UpdateDisplayProcedure: Procedure{

    let label: WKInterfaceLabel
    let text: String

    init(label: WKInterfaceLabel, text: String) {
        self.label = label
        self.text = text
        super.init()
    }

    override func execute() {
        Foundation.OperationQueue.main.addOperation {
            self.label.setText(self.text)
            self.finish()
        }
    }
}
