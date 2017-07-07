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
        let textFont: UIFont = UIFont.systemFont(ofSize: 11.0)
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

    func render(_ size: CGSize) -> UIImage {

        if let image = self.image { return image }

        let lineWidth = options.lineWidth

        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        let bounds = CGRect(origin: CGPoint.zero, size: size)

        let insetDelta = lineWidth / 2.0
        let insetRect =  bounds.insetBy(dx: insetDelta, dy: insetDelta)

        //Ruban
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

        let measureRect = text.boundingRect(with: bounds.size, options: [], attributes: properties, context: nil)
        let textRect = CGRect(x: (bounds.size.width - ceil(measureRect.size.width))/2.0, y: (bounds.size.height - ceil(measureRect.size.height))/2.0, width: ceil(measureRect.width), height: ceil(measureRect.height))

        (text as NSString).draw(in: textRect, withAttributes: properties)

        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        lock.lock()
        defer { lock.unlock() }
        image = renderedImage
        return renderedImage!
    }
}
