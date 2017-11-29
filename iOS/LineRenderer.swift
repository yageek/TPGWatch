//
//  LineRenderer.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit.UIImage

final class LineRenderer {

    struct LineRenderingOptions {
        let lineWidth: CGFloat = 5.0
        let textFont: UIFont = UIFont.preferredFont(forTextStyle: .footnote)
        let backgroundColor: UIColor
        let textColor: UIColor
        let ribonColor: UIColor
    }

    private let lock = NSLock()

    let text: String
    let options: LineRenderingOptions

    fileprivate(set) var image: UIImage?

    var hasRendered: Bool {
        lock.lock()
        defer {
            lock.unlock()
        }
        return image != nil
    }

    init(text: String, options: LineRenderingOptions) {
        self.text = text
        self.options = options
    }

    convenience init?(line: Line) {

        let backgroundColor = UIColor(rgba: line.backgroundColor)
        let textColor = UIColor(rgba: line.textColor)
        let code = line.code
        let ribonColor = UIColor(rgba: line.textColor)

        let options = LineRenderingOptions(backgroundColor: backgroundColor, textColor: textColor, ribonColor: ribonColor)
        self.init(text: code, options: options)
    }

    func render() -> UIImage {
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
        let bezierPath = UIBezierPath(roundedRect: drawRect, cornerRadius: bounds.height/2)
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
        lock.lock()
        defer { lock.unlock() }
        image = renderedImage
        return renderedImage!
    }

    func render(_ size: CGSize) -> UIImage {

        if let image = self.image { return image }

        let lineWidth = options.lineWidth

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        let bounds = CGRect(origin: CGPoint.zero, size: size)

        let insetDelta = lineWidth / 2.0
        let insetRect =  bounds.insetBy(dx: insetDelta, dy: insetDelta)

        // Ruban
        let bezierPath = UIBezierPath(roundedRect: insetRect, cornerRadius: bounds.height/2)
        bezierPath.lineWidth = lineWidth

        options.ribonColor.setStroke()
        options.backgroundColor.setFill()
        bezierPath.stroke()
        bezierPath.fill()

        let properties: [NSAttributedStringKey: Any] = [
            .font: options.textFont,
            .foregroundColor: options.textColor
        ]

        let textBasedMeasure = insetRect.insetBy(dx: 5, dy: 5)
        let measureRect = text.boundingRect(with: textBasedMeasure.size, options: [], attributes: properties, context: nil)
        let textRect = CGRect(x: (textBasedMeasure.size.width - ceil(measureRect.size.width))/2.0, y: (textBasedMeasure.size.height - ceil(measureRect.size.height))/2.0, width: ceil(measureRect.width), height: ceil(measureRect.height))

        (text as NSString).draw(in: textRect, withAttributes: properties)

        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        lock.lock()
        defer { lock.unlock() }
        image = renderedImage
        return renderedImage!
    }
}
