//
//  File.swift
//  
//
//  Created by Chris Eidhof on 03.07.22.
//

import Foundation


public enum Bracket: String, CaseIterable {
    case round = "()"
    case square = "[]"
    case curly = "{}"
    case angle = "<>"
}

extension Array where Element == Doc<String> {
    public var commaList: Doc<String> {
        map { $0 }.joined(separator: ",\(.line)").grouped
    }
}
