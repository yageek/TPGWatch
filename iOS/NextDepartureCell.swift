//
//  NextDepartureCell.swift
//  iOS App
//
//  Created by Yannick Heinrich on 16.10.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

import UIKit

final class NextDepartureCell: UITableViewCell {
    static let identifier = "NextDepartureCell"

    @IBOutlet weak var PMRImage: UIImageView!
    @IBOutlet weak var waitingTimeLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var lineImageView: UIImageView!

    func addImageLine(_ image: UIImage) {
        lineImageView.image = image
    }
}
