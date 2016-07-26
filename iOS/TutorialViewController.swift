//
//  TutorialViewController.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 26.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import UIKit
import Gecco


class TutorialViewController: SpotlightViewController {

    var addButtonCoordinate: CGRect = CGRectZero

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let center = CGPoint(x: CGRectGetMidX(addButtonCoordinate), y: CGRectGetMidY(addButtonCoordinate))
         spotlightView.appear(Spotlight.Oval(center: center, diameter: CGRectGetWidth(addButtonCoordinate)))
    }

}
