//: Playground - noun: a place where people can play

import UIKit
import CoreText

struct LineRenderingOptions {
    let lineWidth: CGFloat = 5.0
    let textFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    let backgroundColor: UIColor
    let textColor: UIColor
    let ribonColor: UIColor
}

func render(text: String, options: LineRenderingOptions) -> UIImage {
    let lineWidth = options.lineWidth
    let lineInset = lineWidth/2.0
    
    // Start from text
    let properties: [NSAttributedStringKey: Any] = [
        .font: options.textFont,
        .foregroundColor: options.textColor
    ]
    
    let textSize = text.boundingRect(with: .zero, options: [.usesFontLeading], attributes: properties, context: nil).size
    
    let vMargin = ceil(textSize.height/1.5)
    let hMargin = ceil(textSize.height/8.0)
    let totalSize = CGSize(width: 2*vMargin + ceil(textSize.width) + lineInset, height: 2*hMargin + ceil(textSize.height) + lineInset)
    
    UIGraphicsBeginImageContextWithOptions(totalSize, false, 0)
    let bounds = CGRect(origin: .zero, size: totalSize)
    
    // Background
    let drawRect = bounds.insetBy(dx: lineInset, dy: lineInset)
    let bezierPath = UIBezierPath(roundedRect: drawRect , cornerRadius: bounds.height/2)
    bezierPath.lineWidth = lineWidth
    options.ribonColor.setStroke()
    options.backgroundColor.setFill()
    bezierPath.stroke()
    bezierPath.fill()

    // Text
    let textRect = CGRect(x: (totalSize.width - ceil(textSize.width))/2.0, y: (totalSize.height - ceil(textSize.height))/2.0, width: ceil(textSize.width), height: ceil(textSize.height))
    (text as NSString).draw(in: textRect, withAttributes: properties)
    
    let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return renderedImage!
}

let options = LineRenderingOptions(backgroundColor: .red, textColor: .white, ribonColor: .blue)

let image = render(text: "123478900009987", options: options)
