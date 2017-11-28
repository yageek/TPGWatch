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

    @IBOutlet weak var refreshItem: UIBarButtonItem!
    // Concurrency
    private let queue: ProcedureQueue = {
        let queue = ProcedureQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    var renderingContext: LinesRendererContext = {
        let rendering = LinesRendererContext(context: Store.shared.viewContext)
        return rendering
    }()

    var stop: Stop?
    var stopURI: URL?

    lazy var loadingBackgroundView: LoadingTableView = {
        let nib = UINib(nibName: "LoadingTableView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! LoadingTableView
    }()

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = stop?.name

        downloadData()
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

    @IBAction func refreshTriggered(_ sender: Any) {
        downloadData(forceDownload: true)
    }

    // MARK: - Helpers
    private func updateUI(record: NextDepartureRecord) {
        clearBackground()

        self.nextDepartures = record.departures.filter { $0.waitingTime != "no more"}
        tableView.reloadData()

        if nextDepartures.isEmpty {
            setNoResults()
        }
    }

    private func downloadData(forceDownload: Bool = false) {
        guard let stop = stop else {
            return
        }

        if forceDownload || nextDepartures.isEmpty {
            downloadNextDepartures(stopCode: stop.code)
        }
    }

    private func downloadNextDepartures(stopCode: String) {

        self.nextDepartures = []
        self.tableView.reloadData()
        self.setLoading()

        refreshItem.isEnabled = false
        let getDepartures = GetNextDeparturesProcedure(code: stopCode) { [unowned self] (record, error) in

            if let error = error {

                if case DecodingError.keyNotFound = error {
                    DispatchQueue.main.async { [unowned self] in
                        self.setNoResults()
                    }
                } else {
                    let title = NSLocalizedString("Error while downloading", comment: "")
                    let message = error.localizedDescription
                    self.presentAlert(title: title, message: message)
                }

            } else if let record = record {
                DispatchQueue.main.async { [unowned self] in
                    self.updateUI(record: record)
                }
            }
        }

        getDepartures.addWillExecuteBlockObserver { [unowned self] (_, _) in
            ProcedureQueue.main.addOperation { [unowned self] in
                self.setLoading()
            }
        }

        getDepartures.addDidFinishBlockObserver { [unowned self] (_, _) in
            ProcedureQueue.main.addOperation { [unowned self] in
                self.refreshItem.isEnabled = true
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
        loadingBackgroundView.setText(NSLocalizedString("No departure found", comment: ""), loading: false)
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

    // MARK: - Restoration
    static let stopURIRestorationKey = "stopURI"
    override func decodeRestorableState(with coder: NSCoder) {
        let url = coder.decodeObject(forKey: NextDeparturesVC.stopURIRestorationKey) as! NSURL
        stopURI = url as URL

        super.decodeRestorableState(with: coder)
    }

    override func encodeRestorableState(with coder: NSCoder) {
        if let stop = stop {
            coder.encode(stop.objectID.uriRepresentation() as NSURL, forKey: NextDeparturesVC.stopURIRestorationKey)
        }
        super.encodeRestorableState(with: coder)
    }

    override func applicationFinishedRestoringState() {
        guard let stopURI = stopURI else { return }
        if let objectID = Store.shared.persistentStoreCoordinator.managedObjectID(forURIRepresentation: stopURI) {
            let stop = Store.shared.viewContext.object(with: objectID) as! Stop
            self.stop = stop
        }
    }
}
