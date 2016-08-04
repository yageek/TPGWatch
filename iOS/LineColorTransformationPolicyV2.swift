//
//  LineColorTransformationPolicyV2.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import CoreData
import UIKit

class LineColorTransformationPolicyV2: NSEntityMigrationPolicy {

    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject, entityMapping mapping: NSEntityMapping, manager: NSMigrationManager) throws {


        let object = NSEntityDescription.insertNewObjectForEntityForName(mapping.destinationEntityName!, inManagedObjectContext: manager.destinationContext)

        object.setValue(sInstance.valueForKey("code"), forKey: "code")

        let ribonColor = sInstance.valueForKey("ribonColor") as! UIColor
        let backgroundColor = sInstance.valueForKey("backgroundColor") as! UIColor
        let textColor = sInstance.valueForKey("textColor") as! UIColor

        object.setValue(ribonColor.hexString, forKey: "ribonColor")

        object.setValue(backgroundColor.hexString, forKey: "backgroundColor")
        object.setValue(textColor.hexString, forKey: "textColor")


        let connections = object.valueForKey("connections") as! NSSet
        let connectionsCode = connections.valueForKey("destinationCode") as! Set<String>

        var tmpConnections: [AnyObject] = []
        for connectionCode in connectionsCode {

            let request = NSFetchRequest(entityName: Connection.EntityName)
            request.predicate = NSPredicate(format: "destinationCode == %@", connectionCode)

            let connection = try manager.sourceContext.executeFetchRequest(request)

            if let connection = connection.first {
                tmpConnections.append(connection)
            }
        }

        let c = NSSet(array: tmpConnections)
        object.setValue(c, forKey: "connections")

        manager.associateSourceInstance(sInstance, withDestinationInstance: object, forEntityMapping: mapping)
    }


}
