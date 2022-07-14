//
//  File.swift
//  
//
//  Created by Chris Eidhof on 14.07.22.
//

import Foundation
import Pretty

public protocol Pretty {
    var doc: Doc<String> { get }
}

extension Doc.StringInterpolation {
    mutating func appendInterpolation(_ p: any Pretty) {
        result += p.doc
    }
}

extension Doc: Pretty where A == String {
    public var doc: Doc<String> { self }
}

extension Int: Pretty {
    public var doc: Doc<String> {
        .text("\(self)")
    }
}
