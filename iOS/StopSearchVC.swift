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
import PKHUD

final class StopSearchVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, LinesRendererContextDelegate {

    // Concurrency
    fileprivate let queue = ProcedureQueue()

    var renderingContext: LinesRendererContext = {
        let rendering = LinesRendererContext(context: Store.shared.viewContext)
        return rendering
    }()

    // Core Data
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    //Search
    fileprivate var searchController: UISearchController?
    fileprivate var filteredStops: [Stop] = []
    fileprivate var searchModeEnabled = false

    // MARK: View lifecycle

    deinit {
        searchController?.view.removeFromSuperview()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        renderingContext.delegate = self
        setupTableView()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            renderingContext.renderLines(stop, cell: cell, indexPath: indexPath)
        }

        return cell
    }

    // MARK: Tableview delegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if searchModeEnabled {
            return nil
        } else {
            if let sectionInfo = fetchedResultsController?.sections?[section] {
                return sectionInfo.name
            }
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggleStopAtIndexPath(indexPath)
    }
    // MARK: Refresh

    @IBAction func refreshTriggered(_ sender: UIRefreshControl) {
        downloadStops()
    }

    // MARK: Helpers
    func setupTableView() {
        let nib = UINib(nibName: "StopCellSearch", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "StopCellSearch")

    }
    func setupFetchController() {
        //Fetch Manager
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Stop.EntityName)

        let entityDescription = NSEntityDescription.entity(forEntityName: Stop.EntityName, in: Store.shared.viewContext)!
        let props = entityDescription.propertiesByName

        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 20
        request.propertiesToFetch = [props["name"]!]

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Store.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        fetchedResultsController = controller
    }

    func setupSearchController() {

        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
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

    fileprivate func toggleStopAtIndexPath(_ indexPath: IndexPath) {

        if let stop = stopAtIndexPath(indexPath), let cell = tableView.cellForRow(at: indexPath) {

            defer {
                setCell(cell as! StopCellSearch, bookmarked: stop.bookmarked)
            }

            stop.bookmarked = !stop.bookmarked
            Store.shared.save()
        }
    }

    fileprivate func stopAtIndexPath(_ indexPath: IndexPath) -> Stop? {
        if searchModeEnabled {
            return filteredStops[indexPath.row]
        } else {
            return fetchedResultsController?.object(at: indexPath) as? Stop
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
            tableView.reloadData()

            if let elements = fetchedResultsController?.fetchedObjects as? [Stop], elements.isEmpty && firstTime {
                downloadStops(showHud: true)
            }
        } catch {
            print("Error in the fetched results controller: \(error).")
        }

        //
        if firstTime {
            self.tableView.setContentOffset(.zero, animated: false)
        }
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
                self.queue.addOperation(alert)
            }
        }

        getStopsOp.completionBlock = {
            ProcedureQueue.main.addOperation {
                self.refreshControl?.endRefreshing()
            }
        }

        if showHud {

            getStopsOp.addWillExecuteBlockObserver(block: { (_, _) in
                ProcedureQueue.main.addOperation {
                    let view = PKHUDProgressView()
                    view.subtitleLabel.text = NSLocalizedString("Loading stops...", comment: "")
                    PKHUD.sharedHUD.contentView = view
                    PKHUD.sharedHUD.show()

                }

            })

            getStopsOp.addDidFinishBlockObserver(block: { (_, _) in
                ProcedureQueue.main.addOperation {
                    PKHUD.sharedHUD.hide()
                }
            })
        }

        queue.addOperation(getStopsOp)

    }
    // MARK: Search

    func updateSearchResults(for searchController: UISearchController) {
        searchModeEnabled = searchController.isActive

        if searchModeEnabled {
            refreshControl?.isEnabled = false

            if let fetchedStops = fetchedResultsController?.fetchedObjects as? [Stop],
                let userInput = searchController.searchBar.text {

                if userInput == "" {
                    filteredStops = fetchedStops
                } else {
                    print("User input:\(userInput)")
                    filteredStops = fetchedStops.filter { return $0.name?.localizedCaseInsensitiveContains(userInput) ?? false }
                }

                print("Searching stops : \(userInput) in \(fetchedStops.count) elements - Found: \(filteredStops.count) elements")
            }
        } else {

            refreshControl?.isEnabled = true
        }
        tableView.reloadData()
    }
    fileprivate func addImageToStopCell(_ image: UIImage, indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? StopCellSearch {
            cell.addImageLine(image)
        }
    }

    // MARK: - LinesRendererContextDelegate
    func context(_ context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: IndexPath) {
        addImageToStopCell(image, indexPath: indexPath)
    }

}
