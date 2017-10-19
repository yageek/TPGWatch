//
//  LoadingTableView.swift
//  iOS App
//
//  Created by Yannick Heinrich on 17.10.17.
//  Copyright © 2017 Yageek. All rights reserved.
//

import UIKit

final class LoadingTableView: UIView {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    func setText(_ text: String, loading: Bool) {
        textLabel.text = text
        loadingIndicator.isHidden = !loading
    }
}
