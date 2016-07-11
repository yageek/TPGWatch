//
//  Line+CoreDataProperties.swift
//  GenevaNextBus
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Line {

    @NSManaged var backgroundColor: NSObject?
    @NSManaged var code: String?
    @NSManaged var ribonColor: NSObject?
    @NSManaged var textColor: NSObject?
    @NSManaged var connections: NSSet?

}
