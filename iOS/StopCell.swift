//
//  StopCell.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit

class StopCell: UITableViewCell {

    static let identifier = "StopCell"
    static let moreHolderImage: UIImage = {

        let options = LineRenderer.LineRenderingOptions(backgroundColor: UIColor.white, textColor: UIColor.black, ribonColor: UIColor.black)

        let render = LineRenderer(text: "...", options: options)
        return render.render(CGSize(width: 40.0, height: 32.0))
    }()

    @IBOutlet weak var stopLabel: UILabel!    
    @IBOutlet weak var stopStackView: UIStackView!

//    func addLineStop(backgroundColor: UIColor, rubanColor: UIColor, textColor: UIColor, text: String) {
    func addLineStop() {
        let stopView = TPGStopView(frame: .zero)
        stopView.backColor = .red
        stopView.textColor = .white
        stopView.rubanColor = .red
        stopView.text = "1"
        stopView.translatesAutoresizingMaskIntoConstraints = false
        
//        stopView.backColor = backgroundColor
//        stopView.rubanColor = rubanColor
//        stopView.textColor = textColor
//        stopView.text = text
        stopStackView.insertArrangedSubview(stopView, at: 0)
    }

    func addImageLine(_ image: UIImage) {
//        let view = UIImageView(image: image)
//        view.contentMode = .scaleAspectFit
//        stopStackView.addArrangedSubview(view)
//
//        if let last = stopStackView.arrangedSubviews.last {
//            let constraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: last, attribute: .width, multiplier: 1.0, constant: 0.0)
//            view.addConstraint(constraint)
//        }
    }

    fileprivate func resetStacks(_ stack: UIStackView) {
        for view in stack.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    func resetStacks() {
      resetStacks(stopStackView)
    }
}
