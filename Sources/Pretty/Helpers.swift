//
//  File.swift
//  
//
//  Created by Chris Eidhof on 03.07.22.
//

import Foundation

extension Doc where A == String {
    public var parens: Self {
        "(\(self))"
        <|>
        "(" <> (.line <> self).nest(indent: 4) <> .line <> ")"
    }
}

public enum Bracket: String, CaseIterable {
    case round = "()"
    case square = "[]"
    case curly = "{}"
    case angle = "<>"
}

extension Array where Element == Doc<String> {
    public func argList(_ bracket: Bracket = .round, indent: String.Width = 4) -> Doc<String> {
        let open = String(bracket.rawValue.first!)
        let close = String(bracket.rawValue.dropFirst())
        let lines = reduce { $0 <> "," <> .line <> $1 }
        let body = lines.flatten <|> (.line <> lines).nest(indent: 4) <> .line
        return "\(open)\(body)\(close)"
    }
    
    public var commaList: Doc<String> {
        reduce { "\($0),\(.line)\($1)" }.grouped
    }
}
