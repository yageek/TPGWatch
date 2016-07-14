//
//  StopSearchVC.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import CoreData
import Operations

final class StopSearchVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, LinesRendererContextDelegate {

    // Concurrency
    private let queue = OperationQueue()
    
    var renderingContext: LinesRendererContext = {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let rendering = LinesRendererContext(context: context)
        return rendering
    }()
    // Core Data
    private var fetchedResultsController:NSFetchedResultsController?

    //Search
    private var searchController:UISearchController?
    private var filteredStops:[Stop] = []
    private var searchModeEnabled = false

    // MARK: View lifecycle

    deinit{
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchedResultsController?.delegate = self
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController?.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchModeEnabled {
            return 1
        } else {
            return fetchedResultsController?.sections?.count ?? 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchModeEnabled {
            return filteredStops.count
        } else {
            let section = fetchedResultsController?.sections?[section]
            return section?.numberOfObjects ?? 0
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCellSearch", forIndexPath: indexPath) as! StopCellSearch

        if let stop = stopAtIndexPath(indexPath) {
            setCell(cell, bookmarked: stop.bookmarked)
            cell.stopLabel?.text = stop.name
            cell.resetStacks()
            renderingContext.renderLines(stop, cell: cell, indexPath: indexPath)
        }

        return cell
    }

    // MARK: Tableview delegate

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if searchModeEnabled {
            return nil
        } else {
            if let sectionInfo = fetchedResultsController?.sections?[section] {
                return sectionInfo.name
            }
        }
        return nil
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        toggleStopAtIndexPath(indexPath)
    }
    
    // MARK: Refresh

    @IBAction func refreshTriggered(sender: UIRefreshControl) {
        downloadStops()
    }

    // MARK: Helpers
    internal func setupTableView() {
        let nib = UINib(nibName: "StopCellSearch", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "StopCellSearch")

    }
    internal func setupFetchController() {
        //Fetch Manager
        let request = NSFetchRequest(entityName: Stop.EntityName)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        let entityDescription = NSEntityDescription.entityForName(Stop.EntityName, inManagedObjectContext: UIMoc())!
        let props = entityDescription.propertiesByName

        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 20
        request.propertiesToFetch = [props["name"]!]

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: "sectionName", cacheName: nil)

        fetchedResultsController = controller
    }

    internal func setupSearchController() {

        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.dimsBackgroundDuringPresentation = false

        self.tableView.tableHeaderView = searchController?.searchBar
        self.tableView.tableFooterView = UIView(frame:CGRectZero)
    }

    private func toggleStopAtIndexPath(indexPath:NSIndexPath) {

        if let stop = stopAtIndexPath(indexPath), let cell = tableView.cellForRowAtIndexPath(indexPath) {


            defer {
                setCell(cell as! StopCellSearch, bookmarked: stop.bookmarked)
            }

            stop.bookmarked = !stop.bookmarked
            save()
        }
    }

    private func stopAtIndexPath(indexPath:NSIndexPath) -> Stop?{
        if searchModeEnabled {
            return filteredStops[indexPath.row]
        } else {
            return fetchedResultsController?.objectAtIndexPath(indexPath) as? Stop
        }
    }

    // MARK: Data update

    func setCell(cell: StopCellSearch, bookmarked: Bool) {

        let image = bookmarked ? UIImage(imageLiteral: "bookmark-on") : UIImage(imageLiteral: "bookmark-off")
        cell.bookmarkImageView.image = image
    }
    internal func updateUI(firstTime firstTime: Bool = false){

        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()

            if let elements = fetchedResultsController?.fetchedObjects as? [Stop]  where elements.count == 0 && firstTime {
                downloadStops()
            }
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }

    internal func downloadStops() {
        let getStopsOp = GetStopsOperation(context: UIMoc(), proxy: Proxy()) { (inner) in

            do {
                try inner()

                NSOperationQueue.mainQueue().addOperationWithBlock {

                    self.updateUI()
                }

            } catch let error {
                print("Error:\(error)")
            }
        }

        let endRefreshingOp = NSBlockOperation {

            self.refreshControl?.endRefreshing()
        }

        endRefreshingOp.addDependency(getStopsOp)

        queue.addOperations(getStopsOp)
        NSOperationQueue.mainQueue().addOperation(endRefreshingOp)

    }
    // MARK: Search

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        searchModeEnabled = searchController.active

        if searchModeEnabled {
            refreshControl?.enabled = false

            if let fetchedStops = fetchedResultsController?.fetchedObjects as? [Stop],
                let userInput = searchController.searchBar.text {

                if userInput == "" {
                    filteredStops = fetchedStops
                } else {
                    filteredStops = filteredStops.filter{ return $0.name?.localizedCaseInsensitiveContainsString(userInput) ?? false}
                }

                print("Searching stops : \(userInput) in \(fetchedStops.count) elements - Found: \(filteredStops.count) elements")
            }
        } else {

            refreshControl?.enabled = true
        }
        tableView.reloadData()
    }
    private func addImageToStopCell(image: UIImage, indexPath: NSIndexPath) {
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? StopCellSearch {
            cell.addImageLine(image)
        }
    }

    // MARK:  LinesRendererContextDelegate
    func context(context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: NSIndexPath) {
        addImageToStopCell(image, indexPath: indexPath)
    }

}
