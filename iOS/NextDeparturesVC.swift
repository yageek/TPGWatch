//
//  NextDeparturesVC.swift
//  iOS App
//
//  Created by Yannick Heinrich on 13.10.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

import UIKit
import ProcedureKit
import ProcedureKitMobile
import TPGSwift
import ProcedureKit

final class NextDeparturesVC: UITableViewController, LinesRendererContextDelegate {

    private var nextDepartures: [NextDepartureRecord.NextDeparture] = []

    // Concurrency
    private let queue = ProcedureQueue()

    var renderingContext: LinesRendererContext = {
        let rendering = LinesRendererContext(context: Store.shared.viewContext)
        return rendering
    }()

    var stop: Stop?

    lazy var loadingBackgroundView: LoadingTableView = {
        let nib = UINib(nibName: "LoadingTableView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! LoadingTableView
    }()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        downloadData(stop: stop)
        renderingContext.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        queue.cancelAllOperations()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nextDepartures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NextDepartureCell.identifier, for: indexPath) as! NextDepartureCell
        let nextDeparture = self.nextDepartures[indexPath.row]

        cell.directionLabel.text = nextDeparture.line.destinationName
        cell.waitingTimeLabel.text = nextDepartureTime(fromRawInfo: nextDeparture.waitingTime)
        if let image = renderingContext.renderLine(code: nextDeparture.line.lineCode, indexPath: indexPath) {
            cell.lineImageView.image = image
        }

        if case .some("PMR") =  nextDeparture.characteristics {
            cell.PMRImage.isHidden = false
        } else {
            cell.PMRImage.isHidden = true
        }
        return cell
    }
    // MARK: - Actions
    @IBAction func unwindToNextDepartures(_ segue: UIStoryboardSegue) { }

    // MARK: - Helpers
    private func updateUI(record: NextDepartureRecord) {
        clearBackground()

        self.nextDepartures = record.departures.filter { $0.waitingTime != "no more"}
        tableView.reloadData()

        if nextDepartures.isEmpty {
            setNoResults()
        }
    }

    private func downloadData(stop: Stop?) {
        guard let stop = stop else {
            return
        }
        downloadNextDepartures(stopCode: stop.code)
    }

    private func downloadNextDepartures(stopCode: String) {

        let getDepartures = GetNextDeparturesProcedure(code: stopCode) { [unowned self] (record, error) in

            if let error = error {
                let title = NSLocalizedString("Error while downloading", comment: "")
                let message = error.localizedDescription
                self.presentAlert(title: title, message: message)

            } else if let record = record {
                DispatchQueue.main.async { [unowned self] in
                    self.updateUI(record: record)
                }
            }
        }

        getDepartures.addWillExecuteBlockObserver { (_, _) in
            ProcedureQueue.main.addOperation { [unowned self] in
                self.setLoading()
            }
        }
        queue.add(operation: getDepartures)
    }

    private func setLoading() {
        loadingBackgroundView.setText(NSLocalizedString("Loading ...", comment: ""), loading: true)
        self.tableView.backgroundView = loadingBackgroundView
    }

    private func clearBackground() {
        self.tableView.backgroundView = nil
    }

    private func setNoResults() {
        loadingBackgroundView.setText(NSLocalizedString("No departures found!", comment: ""), loading: false)
        self.tableView.backgroundView = loadingBackgroundView
    }

    private func presentAlert(title: String, message: String) {
        let alert = AlertProcedure(presentAlertFrom: self)
        alert.title = title
        alert.message = message

        let blockOperation = BlockOperation { [unowned self] in
            self.performSegue(withIdentifier: "unwindToBookmark", sender: self)
        }
        blockOperation.add(dependency: alert)

        self.queue.add(operation: alert)
        OperationQueue.main.addOperation(blockOperation)

    }

    // MARK: - LinesRendererContextDelegate
    func context(_ context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? NextDepartureCell {
            cell.addImageLine(image)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ThermometerVC, let index = tableView.indexPathForSelectedRow {
            destination.departure = nextDepartures[index.row]
            destination.stop = stop
        }
    }
}
