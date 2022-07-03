//
//  File.swift
//  
//
//  Created by Chris Eidhof on 03.07.22.
//

import Foundation

extension Doc where A == String {
    public var parens: Self {
        .choice(
            .text("(") <> self <> .text(")"),
            .text("(") <> .nest(indent: 4, .line <> self) <> .line <> .text(")")
        )
    }
}

public enum Bracket: String, CaseIterable {
    case round = "()"
    case square = "[]"
    case curly = "{}"
    case angle = "<>"
}

extension Array where Element == Doc<String> {
    public func argList(_ bracket: Bracket = .round) -> Doc<String> {
        let open = String(bracket.rawValue.first!)
        let close = String(bracket.rawValue.dropFirst())
        let lines = reduce { $0 <> .text(",") <> .line <> $1 }
        return .choice(
            .text(open) <> lines.flatten <> .text(close),
            .text(open) <> .nest(indent: 4, .line <> lines) <> .line <> .text(close)
        )
    }
    public var commaList: Doc<String> {
        .choice(reduce { l, r in
            l <> .text(", ") <> r
        }, reduce { l, r in
            l <> .text(",") <> .line <> r
        })
    }
}
