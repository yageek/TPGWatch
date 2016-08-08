//
//  UpdateDisplayOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 08.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import Operations
import WatchKit

class UpdateDisplayOperation: Operation {

    let label: WKInterfaceLabel
    let text: String

    init(label: WKInterfaceLabel, text: String) {
        self.label = label
        self.text = text
        super.init()
    }

    override func execute() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.label.setText(self.text)
            self.finish()
        }
    }
}
