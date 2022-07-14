//
//  File.swift
//  
//
//  Created by Chris Eidhof on 14.07.22.
//

import Foundation
import Pretty

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

extension KeyValuePairs: Pretty where Key == String, Value == any Pretty {
    public var doc: Doc<String> {
        argList()
    }
    func argList() -> Doc<String> {
        map { name, value in
            name == "" ? value.doc : "\(name): \(value)"
        }.argList()
    }
}

@dynamicMemberLookup
public struct CalledConstructor: Pretty {
    public var constructor: Constructor
    public var arguments: KeyValuePairs<String, any Pretty>
    public var builder: [any Pretty] = []
    
    
    public var doc: Doc<String> {
        var result: Doc<String> = "\(constructor.name)"
        result += arguments.doc
        if !builder.isEmpty {
            result += .space
            result += builder.map { $0.doc }.joined(separator: .line).braces
        }
        return result
    }
    
    public func builder(@PrettyBuilder contents: () -> [any Pretty]) -> Self {
        assert(self.builder.isEmpty)
        var copy = self
        copy.builder = contents()
        return copy
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
        return base.doc + ("\(.line).\(name)\(arguments)" as Doc<String>).indent(4)
    }
    
    public subscript(dynamicMember name: String) -> UnappliedModifier {
        UnappliedModifier(base: self, name: name)
    }
}

@resultBuilder
public struct PrettyBuilder {
    public static func buildBlock(_ p: any Pretty) -> [Pretty] {
        [p]
    }
    public static func buildBlock(_ components: any Pretty...) -> [Pretty] {
        components
    }
    
    public static func buildOptional(_ component: [Pretty]?) -> [Pretty] {
        component ?? []
    }
    
    public static func buildEither(first component: [Pretty]) -> [Pretty] {
       component
    }
    
    public static func buildEither(second component: [Pretty]) -> [Pretty] {
        component
    }
}
