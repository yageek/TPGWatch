//
//  TimeUtils.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 16.10.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

import Foundation

func nextDepartureTime(fromRawInfo: String) -> String {
    var departureTimeText = "\(fromRawInfo)"
    let motif = "&gt;1h"

    if departureTimeText.contains(motif) {
        departureTimeText = departureTimeText.replacingOccurrences(of: motif, with: ">1") + NSLocalizedString("h", comment: "Shortcut for hour")
    } else {
        departureTimeText += " " + "'"
    }
    return departureTimeText
}
