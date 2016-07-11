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

        let options = LineRenderer.LineRenderingOptions(backgroundColor: UIColor.whiteColor(), textColor: UIColor.blackColor(), ribonColor: UIColor.blackColor())

        let render = LineRenderer(text: "...", options: options)
        return render.render(CGSize(width: 40.0, height: 32.0))
    }()

    @IBOutlet weak var stopLabel: UILabel!
    @IBOutlet weak var topStack: UIStackView!
    @IBOutlet weak var bottomStack: UIStackView!

    private weak var currentFillingStack:UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         self.currentFillingStack = topStack
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func addImageLine(image: UIImage) {

        let finalImage: UIImage
        let count = currentFillingStack.arrangedSubviews.count

        if currentFillingStack === bottomStack && count == 2 {
            finalImage = StopCell.moreHolderImage
        } else {
            finalImage = image
        }

        let view = UIImageView(image: finalImage)
        view.contentMode = .ScaleAspectFit

        if count <= 2 {
            currentFillingStack.addArrangedSubview(view)
        }

        if currentFillingStack === topStack {
            currentFillingStack = bottomStack
        } else {
            currentFillingStack = topStack
        }
    }

    private func resetStacks(stack:UIStackView){
        for view in stack.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    func resetStacks(){
        resetStacks(topStack)
        resetStacks(bottomStack)
        currentFillingStack = topStack
    }
}
