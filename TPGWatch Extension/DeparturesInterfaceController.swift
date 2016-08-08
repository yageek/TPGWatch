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

    @IBOutlet var stopNameLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var lineGroup: WKInterfaceGroup!
    @IBOutlet var lineLabel: WKInterfaceLabel!

    func setLine(text: String, textColor: UIColor, backgroundColor: UIColor) {

        let group = lineGroup
        group.setBackgroundColor(backgroundColor)

        let label = lineLabel

        label.setText(text)
        label.setTextColor(textColor)
    }

}

class DeparturesInterfaceController: WKInterfaceController {


    @IBOutlet var loadingGroup: WKInterfaceGroup!

    @IBOutlet var noDeparturesFoundLabel: WKInterfaceLabel!
    @IBOutlet var errorLabel: WKInterfaceLabel!
    @IBOutlet var departuresTable: WKInterfaceTable!
    @IBOutlet var reloadButton: WKInterfaceButton!

    var queue = OperationQueue()
    var record: ParsedNextDeparturesRecord?

    var stop: [String: AnyObject]  = [:]
    var registery: [String: AnyObject] = [:]
    
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


    override func didDeactivate() {
        super.didDeactivate()
        queue.cancelAllOperations()
    }


    @IBAction func reloadTriggered() {

        self.reloadButton.setHidden(true)
        self.loadingGroup.setHidden(false)
        self.noDeparturesFoundLabel.setHidden(true)
        self.errorLabel.setHidden(true)
        self.departuresTable.setNumberOfRows(0, withRowType: "DepartureInfo")
        fetchDepartures(stop["code"] as! String)
    }

    func fetchDepartures(stopCode: String) {

        self.errorLabel.setHidden(true)
        let op = GetNextDeparturesOperation(code: stopCode) { resultJSON, error in

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

        guard rowCount != 0 else {

            self.noDeparturesFoundLabel.setHidden(false)
            return
        }

        self.noDeparturesFoundLabel.setHidden(true)
        for i in 0 ..< rowCount {

            let row = departuresTable.rowControllerAtIndex(i) as! DepartureInfo
            let departure = departures.departures[i]

            // Name
            let departureName = departure.line.destinationName
            row.stopNameLabel.setText(departureName)

            //Line color
            if let registeryCache = Store.sharedInstance.registeryCache {
                let code = departure.line.lineCode
                let lineInfo = registeryCache[code] as! [String: String]

                row.setLine(code, textColor: UIColor(rgba: lineInfo["textColor"]!), backgroundColor: UIColor(rgba: lineInfo["backgroundColor"]!))

                row.lineGroup.setHidden(false)

            } else {
                row.lineGroup.setHidden(true)
            }



            // Next departure time
            var departureTimeText = "\(departure.waitingTime)"
            let motif = "&gt;1h"

            if departureTimeText.containsString(motif) {
                departureTimeText = departureTimeText.stringByReplacingOccurrencesOfString(motif, withString: ">1") + NSLocalizedString("h", comment: "Shortcut for hour")
            } else {
                departureTimeText += " " + NSLocalizedString("min", comment: "Minutes")
            }

            row.timeLabel.setText(departureTimeText)

        }

    }
}
