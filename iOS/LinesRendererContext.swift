//
//  LinesRendererContext.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import CoreData
import Operations

protocol LinesRendererContextDelegate {
    func context(context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: NSIndexPath)
}

final class LinesRendererContext {

    var queue = OperationQueue()

    var renderers: [String: LineRenderer] = [:]
    var renderersOperation: [String: NSOperation] = [:]
    var context: NSManagedObjectContext

    var delegate: LinesRendererContextDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func renderLines(stop: Stop, cell: StopCell, indexPath: NSIndexPath) {

        guard let stopCode = stop.code else { return }

        let renderSize = CGSize(width: 40.0, height: 32.0)

        let request = NSFetchRequest(entityName: Line.EntityName)
        request.predicate = NSPredicate(format: "ANY connections.stops.code == %@", stopCode)
        request.returnsDistinctResults = true
        request.resultType = .DictionaryResultType

        do {
            let linesDicts = try context.executeFetchRequest(request) as! [[String: AnyObject]]

            for lineDict in linesDicts {
                guard
                    let lineCode = lineDict["code"] as? String,
                    let textColor = lineDict["textColor"] as? UIColor,
                    let backgroundColor = lineDict["backgroundColor"] as? UIColor,
                    let ribonColor = lineDict["ribonColor"] as? UIColor else { continue }

                let renderer = self.renderers[lineCode]

                if let rend = renderer where rend.hasRendered {
                    cell.addImageLine(rend.render(renderSize))
                }

                if renderer == nil {

                    let options = LineRenderer.LineRenderingOptions(backgroundColor: backgroundColor, textColor: textColor, ribonColor: ribonColor)
                    let rend = LineRenderer(text: lineCode, options:  options)


                    print("Renderer for line: \(lineCode)")
                    self.renderers[lineCode] = rend

                    let blockOp = NSBlockOperation {
                        let image = rend.render(renderSize)

                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.delegate?.context(self, finishRenderingImage: image, forIndexPath: indexPath)
                        })
                    }
                    self.renderersOperation[lineCode] = blockOp
                    queue.addOperation(blockOp)
                    
                }
                
            }
            
        } catch let error {
            print("Error:\(error)")
        }
        
    }

}