//
//  File.swift
//  
//
//  Created by Chris Eidhof on 14.07.22.
//

import Foundation
import Pretty

protocol ValueExpression: Pretty {
    var trailingBrace: Bool { get }
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
            result = result <+> "where" <+> w.map { Doc.text($0) }.commaList
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
public struct Constructor: ValueExpression {
    public init(_ name: String) {
        self.name = name
    }
    public var name: String
    
    public static subscript(dynamicMember name: String) -> Self {
        Self(name)
    }
    
    public subscript(dynamicMember name: String) -> MemberExpression {
        MemberExpression(base: self, name: name, skipNewline: true)
    }
    
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, any Pretty>) -> CalledConstructor {
        CalledConstructor(constructor: self, arguments: args)
    }
    
    let trailingBrace = false
    
    public var doc: Doc<String> {
        "\(name)"
    }
}

extension ValueExpression {
    public func trailingClosure(@PrettyBuilder contents: () -> [any Pretty]) -> TrailingClosure {
        TrailingClosure(base: self, contents: contents())
        
    }
    public func emptyTrailingClosure() -> TrailingClosure {
        TrailingClosure(base: self, contents: [])
    }
}

public struct Closure: Pretty {
    public init() { }
    
    public var doc: Doc<String> {
        return "{ }"
    }
}

struct TrailingClosure: ValueExpression {
    var base: ValueExpression
    var contents: [any Pretty]
    
    var trailingBrace: Bool { true }
    
    var doc: Doc<String> {
        let contentsDoc: Doc<String> = contents.isEmpty ? "{}" : contents.map { $0.doc }.joined(separator: .line).braces
        return base.doc <+> contentsDoc
    }
}

extension KeyValuePairs: Pretty where Key == String, Value == any Pretty {
    public var doc: Doc<String> { argList() }
    
    func argList() -> Doc<String> {
        if let l = last?.value, let trailing = l as? Closure {
            return dropLast().map { name, value in
                name == "" ? value.doc : "\(name): \(value)"
            }.argList() <+> trailing.doc
        } else {
            return map { name, value in
                name == "" ? value.doc : "\(name): \(value)"
            }.argList()
        }
    }
}

@dynamicMemberLookup
public struct CalledConstructor: ValueExpression {
    public var constructor: Constructor
    public var arguments: KeyValuePairs<String, any Pretty>
    public var builder: [any Pretty] = []
    
    var trailingBrace: Bool { !builder.isEmpty }
    
    
    public var doc: Doc<String> {
        var result: Doc<String> = "\(constructor.name)"
        let includeArguments = !arguments.isEmpty || builder.isEmpty
        if includeArguments {
            result += arguments.doc
        }
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
    
    public subscript(dynamicMember name: String) -> MemberExpression {
        MemberExpression(base: self, name: name)
    }
}

@dynamicCallable
public struct MemberExpression: ValueExpression {
    var base: ValueExpression
    var name: String
    var skipNewline: Bool = false
    
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, any Pretty>) -> CallExpression {
        CallExpression(base: self, arguments: args)
    }
    
    var trailingBrace: Bool {
        base.trailingBrace
    }
    
    public var doc: Doc<String> {
        if skipNewline {
            return base.doc + (".\(name)" as Doc<String>) <|> base.doc + ("\(.line).\(name)" as Doc<String>).indent(4)
        } else if base.trailingBrace {
            return base.doc + ("\(.line).\(name)" as Doc<String>)
        } else {
            return base.doc + ("\(.line).\(name)" as Doc<String>).indent(4)
        }
    }
}

//@dynamicMemberLookup
//public struct Modifier: ValueExpression {
//    var base: ValueExpression
//    var name: String
//    var arguments: KeyValuePairs<String, any Pretty>
//    var trailingBrace: Bool {
//        base.trailingBrace
//    }
//
//    public var doc: Doc<String> {
//        let line: Doc<String> = "\(.line).\(name)\(arguments)"
//        if trailingBrace {
//            return base.doc + line
//        } else {
//            return base.doc + line.indent(4)
//        }
//    }
//
//    public subscript(dynamicMember name: String) -> UnappliedModifier {
//        UnappliedModifier(base: self, name: name)
//    }
//}

@dynamicMemberLookup
public struct CallExpression: ValueExpression {
    var base: ValueExpression
    var arguments: KeyValuePairs<String, any Pretty>
    var trailingBrace: Bool {
        base.trailingBrace
    }
    
    public var doc: Doc<String> {
        "\(base.doc)\(arguments)"
    }
    
    public subscript(dynamicMember name: String) -> MemberExpression {
        MemberExpression(base: self, name: name)
    }
}
