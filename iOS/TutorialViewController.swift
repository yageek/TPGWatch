//
//  TutorialViewController.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 26.07.16.
//  Copyright © 2016 Yageek. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    var addButtonCoordinate: CGRect = CGRectZero
    var tapGesture: UITapGestureRecognizer!

      override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clearColor()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTriggered))
        tapGesture.enabled = false

        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        startSpotlight()

    }

    func startSpotlight() {

        UIView.animateWithDuration(1.0, delay: 0, options: .CurveEaseOut, animations: {
            let maskLayer = CAShapeLayer()
            let path = CGPathCreateMutable()

            CGPathAddRect(path, nil, self.view.bounds)
            CGPathAddRoundedRect(path, nil, self.addButtonRect(), 5, 5)

            maskLayer.path = path
            maskLayer.fillRule = kCAFillRuleEvenOdd
            maskLayer.opacity = 0.6
            // Set the mask of the view.
            self.view.layer.mask = maskLayer;
            self.view.backgroundColor = UIColor.blackColor()


            }, completion: {(finished) in
                guard finished else { return }
                self.tapGesture.enabled = true
                self.descriptionLabel.hidden = false
        } )
    }

    internal func addButtonRect() -> CGRect {
        let maskOrigin = CGPoint(x: self.addButtonCoordinate.origin.x, y: self.addButtonCoordinate.origin.y - 5.0)
        let maskRect = CGRect(origin: maskOrigin, size: CGSize(width: 30, height: 30))
        return maskRect
    }

    internal func tapTriggered(sender: UITapGestureRecognizer) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
