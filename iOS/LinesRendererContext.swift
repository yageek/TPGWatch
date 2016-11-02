//
//  LinesRendererContext.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 05.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import CoreData
import ProcedureKit

protocol LinesRendererContextDelegate {
    func context(_ context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: IndexPath)
}

final class LinesRendererContext {

    var queue = OperationQueue()

    var renderers: [String: LineRenderer] = [:]
    var renderersOperation: [String: Operation] = [:]
    var context: NSManagedObjectContext

    var delegate: LinesRendererContextDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func renderLines(_ stop: Stop, cell: StopCell, indexPath: IndexPath) {

        guard let stopCode = stop.code else { return }

        let renderSize = CGSize(width: 40.0, height: 32.0)

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Line.EntityName)
        request.predicate = NSPredicate(format: "ANY connections.stops.code == %@", stopCode)
        request.returnsDistinctResults = true
        request.resultType = .dictionaryResultType

        do {
            let linesDicts = try context.fetch(request) as! [[String: AnyObject]]

            for lineDict in linesDicts {
                guard
                    let lineCode = lineDict["code"] as? String,
                    let textColor = lineDict["textColor"] as? String,
                    let backgroundColor = lineDict["backgroundColor"] as? String,
                    let ribonColor = lineDict["ribonColor"] as? String else { continue }

                let renderer = self.renderers[lineCode]

                if let rend = renderer, rend.hasRendered {
                    cell.addImageLine(rend.render(renderSize))
                }

                if renderer == nil {

                    let options = LineRenderer.LineRenderingOptions(backgroundColor: UIColor(rgba: backgroundColor), textColor: UIColor(rgba: textColor), ribonColor: UIColor(rgba: ribonColor))
                    let rend = LineRenderer(text: lineCode, options:  options)

                    self.renderers[lineCode] = rend

                    let blockOp = BlockOperation {
                        let image = rend.render(renderSize)

                        OperationQueue.main.addOperation({
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
