import XCTest
import Pretty
import Foundation

struct Color {
    var red: Int
    var green: Int
    var blue: Int
    var alpha: Int
}

extension Color {
    var doc: Doc<String> {
        let pairs = [
            Doc<String>.text("red: \(red)"),
            .text("green: \(green)"),
            .text("blue: \(blue)"),
            .text("alpha: \(alpha)"),
        ]
        return .text("Color") <> pairs.argList()
    }
}

extension Array where Element == Doc<String> {
    var doc: Doc<String> {
        argList(.square)
    }
}

class Tests2: XCTestCase {
    let color0 = Color(red: 1, green: 0, blue: 0, alpha: 0)
    let color1 = Color(red: 0, green: 1, blue: 0, alpha: 0)
    
    func testStupid() {
        assertPretty(pageWidth: 20, str: """
        hello
            world
        """, doc: .text("hello") <> .nest(indent: 4, .line <> .text("world")))
        
    }
    
    func testColor() {
        assertPretty(pageWidth: 100, str: "Color(red: 1, green: 0, blue: 0, alpha: 0)", doc: color0.doc)
        assertPretty(pageWidth: 20, str: """
        Color(
            red: 1,
            green: 0,
            blue: 0,
            alpha: 0
        )
        """, doc: color0.doc)
    }
    
    func testArray() {
        let input = [color0.doc, color1.doc].doc
        assertPretty(pageWidth: 100, str: """
        [Color(red: 1, green: 0, blue: 0, alpha: 0), Color(red: 0, green: 1, blue: 0, alpha: 0)]
        """, doc: input)
        assertPretty(pageWidth: 80, str: """
        [
            Color(red: 1, green: 0, blue: 0, alpha: 0),
            Color(red: 0, green: 1, blue: 0, alpha: 0)
        ]
        """, doc: input)
        assertPretty(pageWidth: 40, str: """
        [
            Color(
                red: 1,
                green: 0,
                blue: 0,
                alpha: 0
            ),
            Color(
                red: 0,
                green: 1,
                blue: 0,
                alpha: 0
            )
        ]
        """, doc: input)
    }
}
