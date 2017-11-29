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
import TPGSwift
protocol LinesRendererContextDelegate: class {
    func context(_ context: LinesRendererContext, finishRenderingImage image: UIImage, forIndexPath indexPath: IndexPath)
}

final class LinesRendererContext {
    static let renderSize = CGSize(width: 40.0, height: 32.0)
    var queue = ProcedureQueue()

    let lock = NSLock()
    var renderers: [String: LineRenderer] = [:]
    var renderersOperation: [String: Operation] = [:]
    var context: NSManagedObjectContext

    weak var delegate: LinesRendererContextDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
        NotificationCenter.default.addObserver(self, selector: #selector(dynamicSizeChanged(_:)), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func renderLine(lineCode: String, options: LineRenderer.LineRenderingOptions, indexPath: IndexPath) -> UIImage? {
        let renderer = self.renderers[lineCode]

        if let rend = renderer, rend.hasRendered {
            return rend.render(LinesRendererContext.renderSize)
        }

        if renderer == nil {
            let rend = LineRenderer(text: lineCode, options: options)

            self.renderers[lineCode] = rend

            let blockOp = BlockOperation {
                let image = rend.render(LinesRendererContext.renderSize)

                OperationQueue.main.addOperation({
                    self.delegate?.context(self, finishRenderingImage: image, forIndexPath: indexPath)
                })
                self.lock.lock()
                defer {
                    self.lock.unlock()
                }

                self.renderersOperation.removeValue(forKey: lineCode)
            }
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            self.renderersOperation[lineCode] = blockOp
            queue.addOperation(blockOp)
        }
        return nil
    }

    func renderLinesCode(lineDicts: [[String: Any]], indexPath: IndexPath) -> [UIImage] {

        var images = [UIImage]()
        for lineDict in lineDicts {
            guard
                let lineCode = lineDict["code"] as? String,
                let textColor = lineDict["textColor"] as? String,
                let backgroundColor = lineDict["backgroundColor"] as? String,
                let ribonColor = lineDict["ribonColor"] as? String else { continue }

            let options = LineRenderer.LineRenderingOptions(backgroundColor: UIColor(rgba: backgroundColor), textColor: UIColor(rgba: textColor), ribonColor: UIColor(rgba: ribonColor))
            if let image = renderLine(lineCode: lineCode, options: options, indexPath: indexPath) {
                images.append(image)
            }
        }
        return images
    }

    func renderLine(code: String, indexPath: IndexPath) -> UIImage? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Line.EntityName)
        request.predicate = NSPredicate(format: "code == %@", code)
        request.returnsDistinctResults = true
        request.resultType = .dictionaryResultType
        request.fetchLimit = 1

        do {
            let linesDicts = try context.fetch(request) as! [[String: Any]]
            return renderLinesCode(lineDicts: linesDicts, indexPath: indexPath).first
        } catch let error {
            print("Error:\(error)")
        }
        return nil
    }

    func renderLines(_ stopCode: String, indexPath: IndexPath) -> [UIImage] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Line.EntityName)
        request.predicate = NSPredicate(format: "ANY connections.stops.code == %@", stopCode)
        request.returnsDistinctResults = true
        request.resultType = .dictionaryResultType

        do {
            let linesDicts = try context.fetch(request) as! [[String: Any]]
            return renderLinesCode(lineDicts: linesDicts, indexPath: indexPath)
        } catch let error {
            print("Error:\(error)")
        }

        return []
    }

    private func clear() {
        self.lock.lock()

        defer {
            self.lock.unlock()
        }

        for (_, operation) in self.renderersOperation {
            operation.cancel()
        }
        self.renderersOperation.removeAll()
        self.renderers.removeAll()
    }
    // MARK: - Accessibility

    @objc func dynamicSizeChanged(_ notif: Notification) {
        clear()
    }

}
