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


    @IBOutlet var loadingGroup: WKInterfaceGroup!

    @IBOutlet var errorLabel: WKInterfaceLabel!
    @IBOutlet var departuresTable: WKInterfaceTable!
    @IBOutlet var reloadButton: WKInterfaceButton!

    var queue = OperationQueue()
    var record: ParsedNextDeparturesRecord?
    var stop: [String: AnyObject]  = [:]

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        reloadButton.setHidden(true)

        guard let ctx = context as? [String: AnyObject] else {
            print("Unexpected context :\(context)")
            return
        }

        stop = ctx["stop"] as! [String: AnyObject]

        fetchDepartures(stop["code"] as! String)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        queue.cancelAllOperations()
    }


    @IBAction func reloadTriggered() {

        self.reloadButton.setHidden(true)
        self.loadingGroup.setHidden(false)
        self.departuresTable.setNumberOfRows(0, withRowType: "DepartureInfo")
        fetchDepartures(stop["code"] as! String)
    }

    func fetchDepartures(stopCode: String) {

        self.errorLabel.setHidden(true)
        let op = GetNextDepartures(code: stopCode) { resultJSON, error in

            if let error = error {
                print("Error: \(error)")
                dispatch_async(dispatch_get_main_queue()){
                    self.errorLabel.setHidden(false)
                    self.loadingGroup.setHidden(true)
                    self.reloadButton.setHidden(false)
                }

            } else if let result = resultJSON {
                self.record = result
                dispatch_async(dispatch_get_main_queue()){
                    self.loadingGroup.setHidden(true)
                    self.reloadButton.setHidden(false)
                    self.errorLabel.setHidden(true)
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

            let departure = departures.departures[i]

            var departureTimeText = "\(departure.waitingTime)"
            let motif = "&gt;"

            if departureTimeText.containsString(motif) {
                departureTimeText = departureTimeText.stringByReplacingOccurrencesOfString(motif, withString: ">")
            } else {
                departureTimeText += " min"
            }

            let departureName = departure.line.destinationName

            row.stopNameLabel.setText(departureName)
            row.timeLabel.setText(departureTimeText)
        }

    }
}
