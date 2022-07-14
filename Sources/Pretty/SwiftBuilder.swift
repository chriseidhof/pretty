//
//  File.swift
//  
//
//  Created by Chris Eidhof on 14.07.22.
//

import Foundation

public protocol Pretty {
    var doc: Doc<String> { get }
}

extension Doc.StringInterpolation {
    mutating func appendInterpolation(_ p: any Pretty) {
        result = result <> p.doc
    }
}

extension Doc: Pretty where A == String {
    public var doc: Doc<String> { self }
}

let doubleNewline: Doc<String> = .line + .line


extension Doc where A == String {
    /// Indent this block and put braces around it (with the contents on a separate line)
    public var braces: Self {
        "{" <> (.line <> self).nest(indent: 4) <> .line <> "}"
    }
}

public struct Extension: Pretty {
    public init(type: String, where: [String]? = nil, contents: [Pretty]) {
        self.type = type
        self.where = `where`
        self.contents = contents
    }
    
    public var type: String
    public var `where`: [String]?
    public var contents: [Pretty]
    
    public var doc: Doc<String> {
        var result: Doc<String> = "extension \(type)"
        if let w = `where` {
            result = result <+> "where" <+> w.map { .text($0) }.commaList
        }
        result += .space + contents.map { $0.doc }.joined(separator: doubleNewline).braces
        return result
    }
}

public struct VariableModifiers: OptionSet {
    public init(rawValue: Set<String>) {
        self.rawValue = rawValue
    }
    
    public init() { }
    
    mutating public func formUnion(_ other: Self) {
        rawValue.formUnion(other.rawValue)
    }
    
    mutating public func formIntersection(_ other: Self) {
        rawValue.formIntersection(other.rawValue)
    }
    
    mutating public func formSymmetricDifference(_ other: Self) {
        rawValue.formSymmetricDifference(other.rawValue)
    }
    
    public var rawValue: Set<String> = []

    static public var `public`: Self { .init(rawValue: ["public"]) }
    static public var `static`: Self { .init(rawValue: ["static"]) }
}

public struct Variable: Pretty {
    public init(modifiers: VariableModifiers = [], name: String, type: String? = nil, defaultValue: Pretty? = nil) {
        self.modifiers = modifiers
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
    
    public var modifiers: VariableModifiers = []
    public var name: String
    public var type: String?
    public var defaultValue: Pretty?
    
    public var doc: Doc<String> {
        var result: Doc<String> = .empty
        if modifiers.contains(.public) {
            result += "public "
        }
        if modifiers.contains(.static) {
            result += "static "
        }
        result += "var \(name)"
        if let t = type {
            result += ": \(t)"
        }
        if let d = defaultValue {
            result = result <+> "= \(d.doc)"
        }
        return result
    }
}

extension Int: Pretty {
    public var doc: Doc<String> { .text("\(self)") }
}

@dynamicCallable
@dynamicMemberLookup
public struct Constructor {
    public init(_ name: String) {
        self.name = name
    }
    public var name: String
    
    public static subscript(dynamicMember name: String) -> Self {
        Self(name)
    }
    
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, any Pretty>) -> CalledConstructor {
        CalledConstructor(constructor: self, arguments: args)
    }

}

@dynamicMemberLookup
public struct CalledConstructor: Pretty {
    public var constructor: Constructor
    public var arguments: KeyValuePairs<String, any Pretty>
    
    public var doc: Doc<String> {
        return .text(constructor.name) <> arguments.map { name, value in
            "\(name): \(value)"
        }.argList()
    }
    
    public subscript(dynamicMember name: String) -> UnappliedModifier {
        UnappliedModifier(base: self, name: name)
    }
}

@dynamicCallable
public struct UnappliedModifier {
    var base: Pretty
    var name: String
    
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, any Pretty>) -> Modifier {
        Modifier(base: base, name: name, arguments: args)
    }
}

@dynamicMemberLookup
public struct Modifier: Pretty {
    var base: Pretty
    var name: String
    var arguments: KeyValuePairs<String, any Pretty>
    
    public var doc: Doc<String> {
        return base.doc + ("\(.line).\(name)" <> arguments.map { name, value in
            "\(name): \(value)"
        }.argList()).nest(indent: 4)
    }
    
    public subscript(dynamicMember name: String) -> UnappliedModifier {
        UnappliedModifier(base: self, name: name)
    }
}
