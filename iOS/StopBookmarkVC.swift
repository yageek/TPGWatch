//
//  StopBookmarkVC.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import Operations
import TPGSwift
import CoreData

final class StopBookmarkVC: UITableViewController, NSFetchedResultsControllerDelegate, LinesRendererContextDelegate {
    let queue = OperationQueue()
    var renderingContext: LinesRendererContext = {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let rendering = LinesRendererContext(context: context)
        return rendering
    }()


    var fetchedResultsController:NSFetchedResultsController?
    var backgroundLabel: UILabel!


    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        renderingContext.delegate = self
        setupTableView()
        setupFetchController()


        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
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
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]

        return section?.numberOfObjects ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell", forIndexPath: indexPath) as! StopCell

        if let stop = self.fetchedResultsController?.objectAtIndexPath(indexPath) as? Stop {

            cell.resetStacks()
            cell.stopLabel?.text = stop.name
            renderingContext.renderLines(stop, cell: cell, indexPath: indexPath)
        }
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if let stop = fetchedResultsController?.objectAtIndexPath(indexPath) as? Stop {
            stop.bookmarked = false
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if !editing {
            save()
        }
    }

    // MARK: NSFetchedResultsControllerDelegate
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

        guard let indexPath = indexPath else { return }

        self.tableView.beginUpdates()
        switch type {
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        default:
            break;
        }
        self.tableView.endUpdates()
    }

    // MARK: Helpers

    internal func UIMoc() -> NSManagedObjectContext {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        return context
    }


    internal func setupFetchController() {
        let request = NSFetchRequest(entityName: Stop.EntityName)
        request.predicate = NSPredicate(format: "bookmarked == true")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: UIMoc(), sectionNameKeyPath: nil, cacheName: nil)

        controller.delegate = self
        fetchedResultsController = controller
    }

    internal func setupTableView() {
        tableView.tableFooterView = UIView(frame: CGRectZero)

        let label = UILabel(frame: CGRectZero)
        label.textAlignment = .Center
        label.center = tableView.center

        backgroundLabel = label

        let nib = UINib(nibName: "StopCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "StopCell")
    }

    private func updateUI(){
        do {
            try fetchedResultsController?.performFetch()
            if let count = fetchedResultsController?.fetchedObjects?.count where count == 0 {
                setBackgroundText(NSLocalizedString("Empty list", comment: ""))
            } else {
                hideBackgroundText()
            }
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }

        tableView.reloadData()
    }

    func setBackgroundText(text:String){
        backgroundLabel.text = text
        self.tableView.backgroundView = backgroundLabel
    }

    func hideBackgroundText(){
        self.tableView.backgroundView = nil
    }

    private func addImageToStopCell(image: UIImage, indexPath: NSIndexPath) {
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? StopCell {
            cell.addImageLine(image)
        }
    }
    // MARK:  LinesRendererContextDelegate
    func context(context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: NSIndexPath) {
        addImageToStopCell(image, indexPath: indexPath)
    }

   }
