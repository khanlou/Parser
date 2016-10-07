//
//  JSONInitializable.swift
//  Parser
//
//  Created by Soroush Khanlou on 10/7/16.
//  Copyright © 2016 Soroush Khanlou. All rights reserved.
//

import Foundation

protocol JSONInitializable {
    init(parser: Parser) throws
    init?(dictionary: [String: AnyObject])
    init?(optionalDictionary: [String: AnyObject]?)
}

extension JSONInitializable {
    init?(optionalDictionary: [String: AnyObject]?){
        guard let dictionary = optionalDictionary else {
            return nil
        }
        self.init(dictionary: dictionary)
    }
    
    init?(dictionary: [String: AnyObject]) {
        let parser = Parser(dictionary: dictionary)
        try? self.init(parser: parser)
    }
}
