//
//  StopSearchVC.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import CoreData
import ProcedureKit
import ProcedureKitMobile

final class StopSearchVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate, LinesRendererContextDelegate {

    // Concurrency
    private let queue = ProcedureQueue()

    var renderingContext: LinesRendererContext = {
        let rendering = LinesRendererContext(context: Store.shared.viewContext)
        return rendering
    }()

    // Core Data
    private var fetchedResultsController: NSFetchedResultsController<Stop>?

    // Search
    private var searchController: UISearchController?
    private var filteredStops: [Stop] = []
    private var searchModeEnabled = false
    var tableIndexes = [String]()

    // LoadingView
    lazy var loadingBackgroundView: LoadingTableView = {
        let nib = UINib(nibName: "LoadingTableView", bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! LoadingTableView
    }()

    // MARK: View lifecycle

    deinit {
        searchController?.view.removeFromSuperview()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        renderingContext.delegate = self
        setupSearchController()
        setupFetchController()
        updateUI(firstTime: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // HACK: See https://stackoverflow.com/questions/46239883/show-search-bar-in-navigation-bar-without-scrolling-on-ios-11
        if #available(iOS 11, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController?.delegate = nil
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchModeEnabled {
            return 1
        } else {
            return fetchedResultsController?.sections?.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchModeEnabled {
            return filteredStops.count
        } else {
            let section = fetchedResultsController?.sections?[section]
            return section?.numberOfObjects ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StopCellSearch", for: indexPath) as! StopCellSearch

        if let stop = stopAtIndexPath(indexPath) {
            setCell(cell, bookmarked: stop.bookmarked)
            cell.stopLabel?.text = stop.name
            cell.resetStacks()
            for image in renderingContext.renderLines(stop.code, indexPath: indexPath) {
                cell.addImageLine(image)
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchModeEnabled {
            return nil
        }

        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return nil
        }
        return sectionInfo.name
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchModeEnabled {
            return []
        }
        return Array(tableIndexes)
    }

    // MARK: Tableview delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggleStopAtIndexPath(indexPath)
    }
    // MARK: Refresh

    @IBAction func refreshTriggered(_ sender: UIRefreshControl) {
        downloadStops()
    }

    // MARK: Helpers
    func setupFetchController() {
        //Fetch Manager
        let request = NSFetchRequest<Stop>(entityName: Stop.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Store.shared.viewContext, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        fetchedResultsController = controller
    }

    func setupSearchController() {

        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController?.dimsBackgroundDuringPresentation = false
        searchController?.isActive = true

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
            let bar = searchController?.searchBar
            bar?.setSearchFieldBackgroundImage(UIImage(named: "textfield_background"), for: .normal)
            bar?.tintColor = .white
        } else {
            self.tableView.tableHeaderView = searchController?.searchBar
        }

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    private func setLoading(enabled: Bool) {
        if enabled {
            loadingBackgroundView.textLabel.text = NSLocalizedString("Loading ...", comment: "")
            self.tableView.backgroundView = loadingBackgroundView
        } else {
            self.tableView.backgroundView = nil
        }
    }

    private func toggleStopAtIndexPath(_ indexPath: IndexPath) {

        if let stop = stopAtIndexPath(indexPath), let cell = tableView.cellForRow(at: indexPath) {

            defer {
                setCell(cell as! StopCellSearch, bookmarked: stop.bookmarked)
            }

            stop.bookmarked = !stop.bookmarked
            Store.shared.save()
        }
    }

    private func stopAtIndexPath(_ indexPath: IndexPath) -> Stop? {
        if searchModeEnabled {
            return filteredStops[indexPath.row]
        } else {
            return fetchedResultsController?.object(at: indexPath)
        }
    }

    // MARK: Data update
    func setCell(_ cell: StopCellSearch, bookmarked: Bool) {

        let image = bookmarked ? UIImage(imageLiteralResourceName: "bookmark-on") : UIImage(imageLiteralResourceName: "bookmark-off")
        cell.bookmarkImageView.image = image
    }

    func updateUI(firstTime: Bool = false) {

        do {
            try fetchedResultsController?.performFetch()
            updateIndexList()

            tableView.reloadData()
            tableView.reloadSectionIndexTitles()

            if let elements = fetchedResultsController?.fetchedObjects, elements.isEmpty && firstTime {
                downloadStops(showHud: true)
            }
        } catch {
            print("Error in the fetched results controller: \(error).")
        }

        if firstTime {
            self.tableView.setContentOffset(.zero, animated: false)
        }
    }

    private func updateIndexList() {
        guard let objects = fetchedResultsController?.fetchedObjects else { return }
        let firstLetters = objects.flatMap { (stop) -> String? in
            guard let firstLetter = stop.name.first else { return nil}
            return String(firstLetter)
            }.reduce([]) { (index, letter) -> [String] in
                if index.contains(letter) {
                    return index
                }
                return index + [letter]
        }
        self.tableIndexes =  firstLetters
    }

    func downloadStops(showHud: Bool = false) {
        let getStopsOp = GetStopsProcedure(context: Store.shared.viewContext, proxy: WatchProxy.shared) { (inner) in

            do {
                try inner()
                OperationQueue.main.addOperation {
                    self.updateUI()
                }

            } catch let error {
                print("Error during download:\(error)")

                let alert = AlertProcedure(presentAlertFrom: self)
                alert.title = NSLocalizedString("Error while downloading", comment: "")

                if let error = error as? GeneralError {
                    alert.message = error.localizedDescription
                } else {
                    alert.message = NSLocalizedString("An error occurs while downloading. Please retry later", comment: "")
                }

                alert.add(actionWithTitle: NSLocalizedString("Ok", comment: ""), style: .cancel, handler: { [unowned self] (_, _) in
                    self.refreshControl?.endRefreshing()
                })
                self.queue.addOperation(alert)
            }
        }

        getStopsOp.addDidFinishBlockObserver(block: { (_, _) in
            ProcedureQueue.main.addOperation { [unowned self] in
                self.refreshControl?.endRefreshing()
            }
        })

        if showHud {

            getStopsOp.addWillExecuteBlockObserver(block: { (_, _) in
                ProcedureQueue.main.addOperation { [unowned self] in
                    self.setLoading(enabled: true)
                }
            })

            getStopsOp.addDidFinishBlockObserver(block: { (_, _) in
                ProcedureQueue.main.addOperation { [unowned self] in
                    self.setLoading(enabled: false)
                }
            })

        }

        queue.addOperation(getStopsOp)

    }
    // MARK: - UISearchControllerDelegate
    func didDismissSearchController(_ searchController: UISearchController) {
        self.tableView.reloadSectionIndexTitles()
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        self.tableView.reloadSectionIndexTitles()
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        searchModeEnabled = searchController.isActive

        if searchModeEnabled {
            refreshControl?.isEnabled = false

            if let fetchedStops = fetchedResultsController?.fetchedObjects,
                let userInput = searchController.searchBar.text {

                if userInput == "" {
                    filteredStops = fetchedStops
                } else {
                    print("User input:\(userInput)")
                    filteredStops = fetchedStops.filter { return $0.name.localizedCaseInsensitiveContains(userInput) }
                }

                print("Searching stops : \(userInput) in \(fetchedStops.count) elements - Found: \(filteredStops.count) elements")
            }
        } else {

            refreshControl?.isEnabled = true
        }
        tableView.reloadData()
    }

    private func addImageToStopCell(_ image: UIImage, indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? StopCellSearch {
            cell.addImageLine(image)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    // MARK: - LinesRendererContextDelegate
    func context(_ context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: IndexPath) {
        addImageToStopCell(image, indexPath: indexPath)
    }

}
