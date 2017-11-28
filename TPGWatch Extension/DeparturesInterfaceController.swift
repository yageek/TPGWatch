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
import ProcedureKit

final class DeparturesInterfaceController: WKInterfaceController {

    @IBOutlet var loadingGroup: WKInterfaceGroup!
    @IBOutlet var noDeparturesFoundLabel: WKInterfaceLabel!
    @IBOutlet var errorLabel: WKInterfaceLabel!
    @IBOutlet var departuresTable: WKInterfaceTable!
    @IBOutlet var reloadButton: WKInterfaceButton!

    var queue = ProcedureQueue()
    var nextDepartures: [NextDepartureRecord.NextDeparture] = []

    var stop: [String: Any]  = [:]
    var registery: [String: Any] = [:]

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        reloadButton.setHidden(true)

        guard let ctx = context as? [String: Any] else {
            print("Unexpected context :\(String(describing: context))")
            return
        }

        stop = ctx["stop"] as! [String: Any]

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

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let departure = nextDepartures[rowIndex]

        let context: [String: Any] = ["departure": departure, "stop": stop]
        pushController(withName: "ThermometerInterfaceController", context: context)
    }

    // MARK: - Helpers
    func fetchDepartures(_ stopCode: String) {

        self.errorLabel.setHidden(true)
        let op = GetNextDeparturesProcedure(code: stopCode) { resultJSON, error in

            if let error = error {
                if case DecodingError.keyNotFound = error {
                    DispatchQueue.main.async { [unowned self] in
                        self.noDeparturesFoundLabel.setHidden(false)
                        self.errorLabel.setHidden(true)
                        self.loadingGroup.setHidden(true)
                        self.reloadButton.setHidden(false)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.noDeparturesFoundLabel.setHidden(true)
                        self.errorLabel.setHidden(false)
                        self.loadingGroup.setHidden(true)
                        self.reloadButton.setHidden(false)
                    }
                }
            } else if let result = resultJSON {
                self.nextDepartures = result.departures.filter { $0.waitingTime != "no more"}
                DispatchQueue.main.async {
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
        departuresTable.setNumberOfRows(nextDepartures.count, withRowType: "DepartureInfo")
        let rowCount = departuresTable.numberOfRows

        guard !nextDepartures.isEmpty else {

            self.noDeparturesFoundLabel.setHidden(false)
            return
        }

        self.noDeparturesFoundLabel.setHidden(true)
        for i in 0 ..< rowCount {

            let row = departuresTable.rowController(at: i) as! DepartureInfo
            let departure = nextDepartures[i]

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
            let departureTimeText = nextDepartureTime(fromRawInfo: departure.waitingTime)
            row.timeLabel.setText(departureTimeText)

            // PMR
            if case .some("PMR") =  departure.characteristics {
               row.PMRImage.setHidden(false)
            } else {
               row.PMRImage.setHidden(true)
            }
        }

    }
}
