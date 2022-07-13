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
    let words: [Doc<String>] = ["hello", "world", "test"]
    
    func testCommaList() {
        let str = words.commaList
        assertPretty(pageWidth: 100, str: "hello, world, test", doc: str)
        assertPretty(pageWidth: 10, str: "hello,\nworld,\ntest", doc: str)
    }
    
    func testParens() {
        let str = ("hello" as Doc<String>).parens
        assertPretty(pageWidth: 100, str: "(hello)", doc: str)
        assertPretty(pageWidth: 5, str: "(\n    hello\n)", doc: str)
//        assertPretty(pageWidth: 10, str: "hello,\nworld,\ntest", doc: str)
    }
    
    func testCombined() {
        let str = words.argList()
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
