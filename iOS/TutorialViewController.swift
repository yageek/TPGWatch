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
    var addButtonCoordinate: CGRect = CGRect.zero
    var tapGesture: UITapGestureRecognizer!

      override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTriggered))
        tapGesture.isEnabled = false

        self.view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startSpotlight()

    }

    func startSpotlight() {

        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            let maskLayer = CAShapeLayer()
            let path = CGMutablePath()

            CGPathAddRect(path, nil, self.view.bounds)
            path.__addRoundedRect(transform: nil, rect: self.addButtonRect(), cornerWidth: 5, cornerHeight: 5)

            maskLayer.path = path
            maskLayer.fillRule = kCAFillRuleEvenOdd
            maskLayer.opacity = 0.6
            // Set the mask of the view.
            self.view.layer.mask = maskLayer;
            self.view.backgroundColor = UIColor.black


            }, completion: {(finished) in
                guard finished else { return }
                self.tapGesture.isEnabled = true
                self.descriptionLabel.isHidden = false
        } )
    }

    internal func addButtonRect() -> CGRect {
        let maskOrigin = CGPoint(x: self.addButtonCoordinate.origin.x, y: self.addButtonCoordinate.origin.y - 5.0)
        let maskRect = CGRect(origin: maskOrigin, size: CGSize(width: 30, height: 30))
        return maskRect
    }

    internal func tapTriggered(_ sender: UITapGestureRecognizer) {

        self.dismiss(animated: true, completion: nil)
    }

}
