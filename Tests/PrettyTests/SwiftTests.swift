import XCTest
import Pretty
import SwiftBuilder
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

extension Doc where A == String {
    func modifier(name: String) -> Self {
        self <> (.line <> ".\(name)()").indent(4)
    }
}

class Tests2: XCTestCase {
    let color0 = Color(red: 1, green: 0, blue: 0, alpha: 0)
    let color1 = Color(red: 0, green: 1, blue: 0, alpha: 0)
    
    func testStupid() {
        assertPretty(pageWidth: 20, str: """
        hello
            world
        """, doc: "hello" <> (.line <> .text("world")).indent(4))
        
    }
    
    func testSimpleModifier() {
        let base: Doc<String> = "hello"
        let doc = base
            .modifier(name: "hidden")
            .modifier(name: "test")
        assertPretty(pageWidth: 80, str: """
        hello
            .hidden()
            .test()
        """, doc: doc)
        
    }
    
    func testBraceModifier() {
        let base: Doc<String> = "HStack {" <> .line <> "}"
        let doc = base
            .modifier(name: "hidden")
            .modifier(name: "test")
        assertPretty(pageWidth: 80, str: """
        HStack {
        }
            .hidden()
            .test()
        """, doc: doc)
        
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
    
    func testExtension() {
        let e: Extension = Extension(type: "ButtonStyle", where: ["Self == Test"], contents: [
            Variable(modifiers: .public, name: "foo", type: "Bool", defaultValue: "true" as Doc<String>)
        ])
        assertPretty(pageWidth: 100, str: """
        extension ButtonStyle where Self == Test {
            public var foo: Bool = true
        }
        """, doc: e.doc)
        
    }
    
    func testConstructor() {
        let c = Constructor.Rectangle(cornerRadius: 100, width: 200)
        assertPretty(pageWidth: 100, str: """
        Rectangle(cornerRadius: 100, width: 200)
        """, doc: c.doc)
        assertPretty(pageWidth: 30, str: """
        Rectangle(
            cornerRadius: 100,
            width: 200
        )
        """, doc: c.doc)
    }
    
    func testModifier() {
        let c = Constructor.Circle()
            .frame(width: 100)
            .padding()
        assertPretty(pageWidth: 100, str: """
        Circle()
            .frame(width: 100)
            .padding()
        """, doc: c.doc)
    }
    
    func testPrettyBuilder() {
        let c = Constructor.HStack()
            .builder {
                Constructor.Circle()
                    .padding(100)
                Constructor.Rectangle()
            }
        assertPretty(pageWidth: 100, str: """
        HStack {
            Circle()
                .padding(100)
            Rectangle()
        }
        """, doc: c.doc)
    }
    
    func testPrettyBuilderWithModifier() {
        let c = Constructor.HStack()
            .builder {
                Constructor.Circle()
                Constructor.Rectangle()
            }
            .padding(100)
        assertPretty(pageWidth: 100, str: """
        HStack {
            Circle()
            Rectangle()
        }
        .padding(100)
        """, doc: c.doc)
    }


}
