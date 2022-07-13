//
//  File.swift
//  
//
//  Created by Chris Eidhof on 13.07.22.
//

import Foundation

extension Doc: ExpressibleByUnicodeScalarLiteral where A == String {
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(stringLiteral: String(value))
    }
}

extension Doc: ExpressibleByExtendedGraphemeClusterLiteral where A == String {
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Doc: ExpressibleByStringLiteral, ExpressibleByStringInterpolation where A == String {
    
    
    public struct StringInterpolation: StringInterpolationProtocol {
        // start with an empty string
        var result: Doc<String> = .empty
        
        public init(literalCapacity: Int, interpolationCount: Int) {
        }
        
        mutating public func appendLiteral(_ literal: String) {
            result = result <> .text(literal)
        }
        
        mutating public func appendInterpolation(_ doc: Doc<String>) {
            result = result <> doc
        }
        
        mutating public func appendInterpolation(_ doc: String) {
            result = result <> .text(doc)
        }
    }
    
    public init(stringLiteral value: String) {
        self = .text(value)
    }
    
    public init(stringInterpolation: StringInterpolation) {
        self = stringInterpolation.result
    }
}
