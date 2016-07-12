//
//  DeparturesInterfaceController.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 12.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import WatchKit
import Foundation
import TPGSwift

class DeparturesInterfaceController: WKInterfaceController {

    var stop: [String: AnyObject]?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let stop = context as? [String: AnyObject] else {
            print("Unexpected context :\(context)")
            return
        }
        self.stop = stop

        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
