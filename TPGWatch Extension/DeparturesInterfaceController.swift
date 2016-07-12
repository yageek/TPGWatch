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


class DepartureInfo: NSObject {

    @IBOutlet var lineImageView: WKInterfaceImage!
    @IBOutlet var stopNameLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
}
class DeparturesInterfaceController: WKInterfaceController {


    @IBOutlet var departuresTable: WKInterfaceTable!
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
                self.record = result
                dispatch_async(dispatch_get_main_queue()){
                    self.reloadData()
                }
            }
        }

        queue.addOperation(op)
    }

    func reloadData() {
        guard let departures = record else { return }

        departuresTable.setNumberOfRows(departures.departures.count, withRowType: "DepartureInfo")
        let rowCount = departuresTable.numberOfRows

        for i in 0 ..< rowCount {

            let row = departuresTable.rowControllerAtIndex(i) as! DepartureInfo
            let departureTime = departures.departures[i].waitingTime
            row.stopNameLabel.setText(departureTime)
        }

    }
}
