//
//  Parser.swift
//  Parser
//
//  Created by Soroush Khanlou on 10/7/16.
//  Copyright © 2016 Soroush Khanlou. All rights reserved.
//

import Foundation

struct ParserError: Error {
    let message: String
}

struct Parser {
    let dictionary: [String: AnyObject]?
    
    init(dictionary: [String: AnyObject]?) {
        self.dictionary = dictionary
    }
    
    func fetch<T>(_ key: String) throws -> T {
        let fetchedOptional = dictionary?[key]
        guard let fetched = fetchedOptional else  {
            throw ParserError(message: "The key '\(key)' was not found.")
        }
        guard let typed = fetched as? T else {
            throw ParserError(message: "The key '\(key)' was not the right type \(T.self). It had value '\(fetched).'")
        }
        return typed
    }
    
    func fetchOptional<T>(_ key: String) throws -> T? {
        let fetchedOptional = dictionary?[key]
        guard let fetched = fetchedOptional else {
            return nil
        }
        if fetched is NSNull {
            return nil
        }
        guard let typed = fetched as? T else {
            throw ParserError(message: "The key '\(key)' was present, but did not have the right type. It had value '\(fetched).'")
        }
        return typed
    }
    
    func fetch<T, U>(_ key: String, transformation: (T) -> U?) throws -> U {
        let fetched: T = try fetch(key)
        guard let transformed = transformation(fetched) else {
            throw ParserError(message: "The value '\(fetched)' at key '\(key)' could not be transformed.")
        }
        return transformed
    }
    
    func fetchOptional<T, U>(_ key: String, transformation: (T) -> U?) throws -> U? {
        let fetchedOptional: T? = try fetchOptional(key)
        return fetchedOptional.flatMap(transformation)
    }
    
    func fetchArray<T, U>(_ key: String, transformation: (T) -> U?) throws -> [U] {
        let fetched: [T] = try fetch(key)
        return fetched.flatMap(transformation)
    }
    
    func fetchOptionalArray<T>(_ key: String) throws -> [T] {
        let fetchedOptional: [T]? = try fetchOptional(key)
        return fetchedOptional ?? []
    }
    
    func fetchOptionalArray<T, U>(_ key: String, transformation: (T) -> U?) throws -> [U] {
        let fetchedOptional: [T]? = try fetchOptional(key)
        guard let fetched = fetchedOptional else {
            return []
        }
        return fetched.flatMap(transformation)
    }
}
