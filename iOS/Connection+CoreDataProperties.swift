//
//  Connection+CoreDataProperties.swift
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

extension Connection {

    @NSManaged var destinationCode: String?
    @NSManaged var destinationName: String?
    @NSManaged var line: Line?
    @NSManaged var stops: Stop?

}
