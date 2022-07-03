//
//  File.swift
//  
//
//  Created by Chris Eidhof on 03.07.22.
//

import Foundation
import Pretty
import XCTest

class HelperTests: XCTestCase {
    func testCommaList() {
        let str = ["hello", "world", "test"].map { Doc<String>.text($0) }.commaList
        assertPretty(pageWidth: 100, str: "hello, world, test", doc: str)
        assertPretty(pageWidth: 10, str: "hello,\nworld,\ntest", doc: str)
    }
    
    func testParens() {
        let str = Doc<String>.text("hello").parens
        assertPretty(pageWidth: 100, str: "(hello)", doc: str)
        assertPretty(pageWidth: 5, str: "(\n    hello\n)", doc: str)
//        assertPretty(pageWidth: 10, str: "hello,\nworld,\ntest", doc: str)
    }
    
    func testCombined() {
        let str = ["hello", "world", "test"].map { Doc<String>.text($0) }
            .argList()
        assertPretty(pageWidth: 100, str: "(hello, world, test)", doc: str)
        assertPretty(pageWidth: 10, str: """
        (
            hello,
            world,
            test
        )
        """, doc: str)
    }
}
