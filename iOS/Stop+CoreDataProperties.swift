//
//  Stop+CoreDataProperties.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Stop {

    @NSManaged var bookmarked: Bool
    @NSManaged var code: String?
    @NSManaged var name: String?
    @NSManaged var connections: NSSet?


    @NSManaged func addConnectionsObject(_ value: Connection)
}
