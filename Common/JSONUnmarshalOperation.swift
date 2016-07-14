//
//  JSONUnmarshalOperation.swift
//  TPGWatch
//
//  Created by Yannick Heinrich on 04.07.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Operations

final class JSONUnmarshalOperation: Operation, ResultOperationType, AutomaticInjectionOperationType {

    var requirement: NSURL?
    private(set) var result: AnyObject?

    override init() {
        super.init()
        self.name = "Unmarshal operation"
    }

    override func execute() {
        guard !cancelled else { return }
        
        guard let requirement = requirement else { return }
        
        guard let stream = NSInputStream(URL: requirement) else {
            finish()
            return;
        }

        stream.open()

        defer {
            stream.close()
        }

        do {
            result = try NSJSONSerialization.JSONObjectWithStream(stream, options: [])
            self.finish()
        } catch let error {
            self.finish(error)
            return
        }
    }
}
