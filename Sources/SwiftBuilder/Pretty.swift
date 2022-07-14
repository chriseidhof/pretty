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

extension Array: Pretty where Element: Pretty {
    public var doc: Doc<String> {
        map { $0.doc }.argList(.square)
    }
}

extension CGFloat: Pretty {
    public var doc: Doc<String> {
        .text("\(self)")
    }
    
}

extension String: Pretty {
    public var doc: Doc<String> {
        assert(!contains("\"") && !contains("\n"), "TODO")
        return "\"\(self)\""
    }
}

extension FloatingPoint where Self: CVarArg {
    public func precision(_ digits: Int) -> Doc<String> {
        .text(String(format: "%.\(digits)f", locale: .init(identifier: "en_us"), self))
    }
}

extension Double: Pretty {
    public var doc: Doc<String> {
        .text("\(self)")
    }
}
