//
//  StopBookmarkVC.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import ProcedureKit
import TPGSwift
import CoreData

final class StopBookmarkVC: UITableViewController, NSFetchedResultsControllerDelegate, LinesRendererContextDelegate {
    let queue = ProcedureQueue()
    var renderingContext: LinesRendererContext = {
        let rendering = LinesRendererContext(context: Store.shared.viewContext)
        return rendering
    }()

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var backgroundLabel: UILabel!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        renderingContext.delegate = self
        setupTableView()
        setupFetchController()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        fetchedResultsController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController?.delegate = nil
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]

        return section?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StopCell", for: indexPath) as! StopCell

        if let stop = self.fetchedResultsController?.object(at: indexPath) as? Stop {

            cell.resetStacks()
            cell.stopLabel?.text = stop.name
            renderingContext.renderLines(stop, cell: cell, indexPath: indexPath)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if let stop = fetchedResultsController?.object(at: indexPath) as? Stop {
            stop.bookmarked = false
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if !editing {
            // START Syncing
            Store.shared.save()
            updateCentralLabel()
        }
    }

    // MARK: NSFetchedResultsControllerDelegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        guard let indexPath = indexPath else { return }

        self.tableView.beginUpdates()
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
        self.tableView.endUpdates()
    }

    // MARK: Helpers
    internal func setupFetchController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Stop.EntityName)
        request.predicate = NSPredicate(format: "bookmarked == true")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Store.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        controller.delegate = self
        fetchedResultsController = controller
    }

    internal func setupTableView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.center = tableView.center

        backgroundLabel = label

        let nib = UINib(nibName: "StopCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StopCell")
    }

    fileprivate func updateUI() {
        do {
            try fetchedResultsController?.performFetch()
            updateCentralLabel()
        } catch {
            print("Error in the fetched results controller: \(error).")
        }

        tableView.reloadData()
    }

    fileprivate func updateCentralLabel() {
        //swiftlint:disable empty_count
        if let count = fetchedResultsController?.fetchedObjects?.count, count == 0 {
            setBackgroundText(NSLocalizedString("Empty list", comment: "On the first screen, when no bookmarks are in the list"))
        } else {
            hideBackgroundText()
        }
        //swiftlint:enable empty_count

    }

    func setBackgroundText(_ text: String) {
        backgroundLabel.text = text
        self.tableView.backgroundView = backgroundLabel
    }

    func hideBackgroundText() {
        self.tableView.backgroundView = nil
    }

    fileprivate func addImageToStopCell(_ image: UIImage, indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? StopCell {
            cell.addImageLine(image)
        }
    }
    // MARK: - LinesRendererContextDelegate
    func context(_ context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: IndexPath) {
        addImageToStopCell(image, indexPath: indexPath)
    }

    func addButtonCoord() -> CGRect {

        guard let navigationController = UIApplication.shared.windows.first?.rootViewController as? UINavigationController else { return CGRect.zero }

        let buttonItems = navigationController.navigationBar.subviews.filter { (view) -> Bool in
            return view.isKind(of: UIControl.self)
        }

        guard let addButton = buttonItems.first as? UIControl else { return CGRect.zero }
        return addButton.convert(addButton.frame, to: nil)
    }
   }
