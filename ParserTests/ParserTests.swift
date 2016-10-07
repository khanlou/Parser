//
//  ParserTests.swift
//  ParserTests
//
//  Created by Soroush Khanlou on 10/7/16.
//  Copyright © 2016 Soroush Khanlou. All rights reserved.
//

import XCTest

@testable import Parser

class ParserTests: XCTestCase {
    let dictionary: [String: AnyObject] = [
        "aNumber": 123 as AnyObject,
        "aURL": "http://google.com" as AnyObject,
        "aString": "asdf" as AnyObject,
        "anArray": [
            "a",
            "b",
            ] as AnyObject,
        "anObject": [
            "key1": "value1" as AnyObject,
            "key2": 1 as AnyObject,
            ] as AnyObject,
        "aNullValue": NSNull()
    ]
    
    func testNilDictionary() {
        let parser = Parser(dictionary: nil)
        
        XCTAssertThrowsError(try parser.fetch("asdf") as String)
        
        XCTAssertNil(try parser.fetchOptional("jkl") as String?)
        
        XCTAssertEqual(try parser.fetchOptionalArray("jkl") as [String], [])
    }
    
    func testValidDictionary() {
        let parser = Parser(dictionary: dictionary)
        
        XCTAssertEqual(try parser.fetch("aNumber") as Int, 123)
        XCTAssertEqual(try parser.fetch("aString") as String, "asdf")
        
        XCTAssertThrowsError(try parser.fetch("aString") as Int)
        
        XCTAssertEqual(try parser.fetch("aURL") { URL(string: $0) }, URL(string: "http://google.com"))
        XCTAssertThrowsError(try parser.fetch("notAURL") { URL(string: $0) })
        XCTAssertEqual(try parser.fetchOptional("notAURL") { URL(string: $0) }, nil)
        XCTAssertThrowsError(try parser.fetchOptional("aNumber") { URL(string: $0) })
    }
    
    func testFetchArray() {
        enum ParsableEnum: String {
            case a
            case b
        }
        let parser = Parser(dictionary: dictionary)
        XCTAssertEqual(try parser.fetchArray("anArray") { ParsableEnum(rawValue: $0) }, [.a, .b])
        XCTAssertEqual(try parser.fetch("anArray"), ["a", "b"])
    }
    
    func testFetchNested() {
        struct ParsableStruct: JSONInitializable {
            let key1: String
            let key2: Int
            
            init(parser: Parser) throws {
                key1 = try parser.fetch("key1")
                key2 = try parser.fetch("key2")
            }
        }
        let parser = Parser(dictionary: dictionary)
        let aStruct: ParsableStruct? = try? parser.fetch("anObject") { ParsableStruct(dictionary: $0) }
        XCTAssertNotNil(aStruct)
        XCTAssertEqual(aStruct?.key1, "value1")
        XCTAssertEqual(aStruct?.key2, 1)
        
    }
    
    func testFetchOptionalNullValue() {
        let parser = Parser(dictionary: dictionary)
        XCTAssertNil(try parser.fetchOptional("aNullValue"))
    }
}
