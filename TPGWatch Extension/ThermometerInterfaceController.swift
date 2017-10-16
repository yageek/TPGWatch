//
//  ThermometerInterfaceController.swift
//  TPGWatch Extension
//
//  Created by Yannick Heinrich on 17.10.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

import WatchKit
import Foundation
import TPGSwift
import ProcedureKit

final class ThermometerInterfaceController: WKInterfaceController {

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    // MARK: - DI and properties
    let queue = ProcedureQueue()

    var departure: NextDepartureRecord.NextDeparture?
    var steps: [Step] = []

    // MARK: - Outlets
    @IBOutlet var loadButton: WKInterfaceButton!
    @IBOutlet var thermometerTable: WKInterfaceTable!
    @IBOutlet var loadGroup: WKInterfaceGroup!
    @IBOutlet var noDepartureFoundLabel: WKInterfaceLabel!
    @IBOutlet var errorLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Initial state is loading
        loadButton.setHidden(true)

        guard let context = context as? [String: Any], let departure = context["departure"] as? NextDepartureRecord.NextDeparture, let stop  = context["stop"] as? [String: Any] else {
            pop()
            return
        }
        self.departure = departure
        setTitle(stop["name"] as? String)
    }

    // MARK: - Interface lifecycle
    override func willActivate() {
        super.willActivate()
        downloadData()
    }

    // MARK: - Actions
    @IBAction func reloadTriggered() {
        downloadData()
    }
    // MARK: - Helpers

    func downloadData() {
        guard let departure = departure, let departureCode = departure.code else {
            pop()
            return
        }

        thermometerTable.setNumberOfRows(0, withRowType: "ThermometerInfo")
        self.loadGroup.setHidden(false)
        self.errorLabel.setHidden(true)
        self.noDepartureFoundLabel.setHidden(true)
        self.loadButton.setHidden(true)
        downloadThermometer(departureCode: departureCode)
    }

    func downloadThermometer(departureCode: Int) {

        let thermometer = GetThermometerProcedure(departureCode: departureCode) { [unowned self] (thermometer, error) in
            if let error = error {
                print("Error during thermometer get: \(error)")

                DispatchQueue.main.async {
                    self.loadButton.setHidden(false)
                    self.errorLabel.setHidden(false)
                }
            } else if let thermometer = thermometer {
                DispatchQueue.main.async {
                    self.updateUI(thermometer: thermometer)
                }
            }
        }

        queue.add(operation: thermometer)
    }

    private func updateUI(thermometer: Thermometer) {
        self.loadGroup.setHidden(true)
        self.loadButton.setHidden(false)

        self.steps = thermometer.steps.filter { $0.arrivalTime != nil }
        let stepCount = steps.count
        thermometerTable.setNumberOfRows(stepCount, withRowType: "ThermometerInfo")

        guard !steps.isEmpty else {
            self.noDepartureFoundLabel.setHidden(false)
            return
        }

        self.noDepartureFoundLabel.setHidden(true)

        for i in 0 ..< stepCount {

            let row = thermometerTable.rowController(at: i) as! ThermometerInfo
            let step = steps[i]

            // Name
            row.stopLabel.setText(step.stop.name)

            // Waiting
            row.timeLabel.setText("\(step.arrivalTime!)'")

            // Hour time
            row.hourLabel.setText(formatter.string(from: step.timestamp))
        }
    }
}
