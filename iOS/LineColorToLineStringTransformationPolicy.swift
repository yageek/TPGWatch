//
//  LineColorToLineStringTransformationPolicy.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.08.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import CoreData
import UIKit

final class LineColorToLineStringTransformationPolicy: NSEntityMigrationPolicy {

    @objc func colorToColorHex(_ color: UIColor) -> String {
        return color.hexString
    }

    @objc func colorHexToColor(_ colorHex: String) -> UIColor {
        return UIColor(rgba: colorHex)
    }

}
