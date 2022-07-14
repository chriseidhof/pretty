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
        return Constructor.Color(red: red, green: green, blue: blue, alpha: alpha).doc
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
    
    func testStaticMethod() {
        let c = Constructor.NSFont.systemFont(ofSize: 12)
        assertPretty(pageWidth: 100, str: """
        NSFont.systemFont(ofSize: 12)
        """, doc: c.doc)
        assertPretty(pageWidth: 20, str: """
        NSFont.systemFont(
            ofSize: 12
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
    
    func testTrailingClosure() {
        let c = Constructor.Button("Hello", Closure())
        assertPretty(pageWidth: 100, str: """
        Button("Hello") { }
        """, doc: c.doc)
    }
    
    func _testString() {
        let str = """
        One
        Two
        """
        let c = Constructor.Button(str, Closure())
        assertPretty(pageWidth: 100, str: #"""
        Button("""
        One
        Two
        """) { }
        """#, doc: c.doc)
    }



}
