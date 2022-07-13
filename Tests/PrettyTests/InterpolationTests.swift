import Foundation
import Pretty
import XCTest

class InterpolationTests: XCTestCase {
    func testStringLiteral() {
        let doc: Doc<String> = "hello, world"
        assertPretty(pageWidth: 100, str: "hello, world", doc: doc)
    }
    
    func testInterpolation() {
        let greeting: Doc<String> = "hello"
        let doc: Doc<String> = "\(greeting), world"
        assertPretty(pageWidth: 100, str: "hello, world", doc: doc)
    }
}
