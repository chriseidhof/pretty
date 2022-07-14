//
//  File.swift
//  
//
//  Created by Chris Eidhof on 14.07.22.
//

import Foundation
import Pretty

extension Doc where A == String {
    public var parens: Self {
        "(\(self))"
        <|>
        "(" + (.line <> self).indent(4) + .line + ")"
    }
}

extension Array where Element == Doc<String> {
    public func argList(_ bracket: Bracket = .round) -> Doc<String> {
        let open = String(bracket.rawValue.first!)
        let close = String(bracket.rawValue.dropFirst())
        let lines = joined(separator: "," <> .line)
        let body = lines.flatten <|> (.line <> lines).indent(4) <> .line
        return "\(open)\(body)\(close)"
    }
    
    public var commaList: Doc<String> {
        joined(separator: ",\(.line)").grouped
    }
}

let doubleNewline: Doc<String> = .line + .line

extension Doc where A == String {
    /// Indent this block and put braces around it (with the contents on a separate line)
    public var braces: Self {
        "{" <> (.line <> self).indent(4) <> .line <> "}"
    }
}
