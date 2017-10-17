//
//  ThermometerVC.swift
//  iOS App
//
//  Created by Yannick Heinrich on 16.10.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

import UIKit
import TPGSwift
import ProcedureKit
import ProcedureKitMobile

final class ThermometerVC: UITableViewController, LinesRendererContextDelegate {

    // MARK: - DI and properties
    var departure: NextDepartureRecord.NextDeparture?
    var stop: Stop?

    private var thermometer: Thermometer?
    private var steps: [Step] = []
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()

    lazy var loadingBackgroundView: UIView = {
        let nib = UINib(nibName: "LoadingTableView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }()

    // Concurrency
    private let queue = ProcedureQueue()

    lazy var renderingContext: LinesRendererContext = {
        let rendering = LinesRendererContext(context: Store.shared.viewContext)
        rendering.delegate = self
        return rendering
    }()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        self.title = "\(stop?.name ?? "??")"
        downloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.steps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThermometerCell", for: indexPath) as! ThermometerCell
        let step = steps[indexPath.row]

        #if DEBUG
            print("Stop Name: \(step.stop.name)")
            print("Arrival Time: \(step.arrivalTime)")
            print("Date: \(step.timestamp)")
        #endif

        cell.resetStacks()
        for image in renderingContext.renderLines(step.stop.code, indexPath: indexPath) {
            cell.addImageLine(image)
        }

        cell.stopLabel.text = step.stop.name
        if let time = step.arrivalTime {
            cell.timeLabel.text = "\(time)'"
            cell.timeLabel.isHidden = false
        } else {
            cell.timeLabel.isHidden = true
        }

        cell.hourLabel.text = formatter.string(from: step.timestamp)

        return cell
    }
    // MARK: - Setup Data
    func downloadData() {
        guard let departureCode = departure?.code else {
            return
        }
        downloadThermometer(departureCode: departureCode)
    }

    private func updateUI(thermometer: Thermometer) {
        DispatchQueue.main.async { [unowned self] in
            self.thermometer = thermometer
            self.steps = thermometer.steps.filter { $0.arrivalTime != nil }
            self.tableView.reloadData()
        }
    }

    func downloadThermometer(departureCode: Int) {

        let thermometer = GetThermometerProcedure(departureCode: departureCode) { [unowned self] (thermometer, error) in
            if let error = error {
                let title = NSLocalizedString("Error", comment: "")
                let message = error.localizedDescription
                self.presentAlert(title: title, message: message)
            } else if let thermometer = thermometer {
                self.updateUI(thermometer: thermometer)
            }
        }

        thermometer.addWillExecuteBlockObserver { (_, _) in
            ProcedureQueue.main.addOperation { [unowned self] in
                self.tableView.backgroundView = self.loadingBackgroundView
            }
        }

        thermometer.addDidFinishBlockObserver(block: { (_, _) in
            ProcedureQueue.main.addOperation { [unowned self] in
                self.tableView.backgroundView = nil
            }
        })

        queue.add(operation: thermometer)
    }
    // MARK: - Helpers
    private func presentAlert(title: String, message: String) {
        let alert = AlertProcedure(presentAlertFrom: self)
        alert.title = title
        alert.message = message

        let block  = BlockOperation { [unowned self] in
            self.performSegue(withIdentifier: "unwindToNextDepartures", sender: self)
        }

        block.addDependency(alert)
        self.queue.add(operation: alert)
        OperationQueue.main.addOperation(block)
    }

    // MARK: - LinesRendererContextDelegate
    func context(_ context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? StopCell {
            cell.addImageLine(image)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}
