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
import Operations

class DeparturesInterfaceController: WKInterfaceController {

    var queue = OperationQueue()
    var record: ParsedNextDeparturesRecord?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        guard let stop = context as? [String: AnyObject] else {
            print("Unexpected context :\(context)")
            return
        }

        fetchDepartures(stop["code"] as! String)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }


    func fetchDepartures(stopCode: String) {

        let op = GetNextDepartures(code: stopCode) { resultJSON, error in

            if let error = error {
                print("Error: \(error)")
            } else if let result = resultJSON {

            }
        }

        queue.addOperation(op)
    }

    func reloadData() {
        guard let departures = record else { return }

        bookmarkedStopsTable.setNumberOfRows(stops.count, withRowType: "BookmarkedStop")
        let rowCount = bookmarkedStopsTable.numberOfRows

        for i in 0 ..< rowCount {

            let row = bookmarkedStopsTable.rowControllerAtIndex(i) as! BookmarkedStop
            let stopName = stops[i]["name"] as! String
            row.stopLabel.setText(stopName)
        }

    }
}
