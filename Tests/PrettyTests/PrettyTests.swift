import XCTest
import Pretty

func assertPretty(pageWidth: Int, str: String, doc: Doc<String>, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(doc.renderPretty(width: pageWidth), str, file: file, line: line)
}

// Stolen from https://github.com/bkase/DoctorPretty
class Tests: XCTestCase {
    func testSimpleConstructors() {
        assertPretty(pageWidth: 80, str: "", doc: Doc.empty)
        assertPretty(pageWidth: 80, str: "a", doc: Doc.text("a"))
        assertPretty(pageWidth: 80, str: "text...", doc: Doc.text("text..."))
        assertPretty(pageWidth: 80, str: "\n", doc: Doc.line)
    }
    
//    func testFlatAltConstructor() {
//        assertPretty(pageWidth: 80, str: "x", doc: .flatAlt(primary: .text("x"), whenFlattened: .text("y")))
//        assertPretty(pageWidth: 80, str: "y", doc: Doc.flatAlt(primary: .text("x"), whenFlattened: .text("y")).flattened)
//    }
    
    func testCat() {
        assertPretty(pageWidth: 80, str: "some code", doc: .text("some") <> .space <> .text("code"))
    }
    
    func testNest() {
        assertPretty(
            pageWidth: 80,
            str: "foo bar",
            doc: .text("foo") <+> .nest(indent: 2, .text("bar"))
        )

        assertPretty(
            pageWidth: 80,
            str: "foo\n  bar",
            doc: .text("foo") <> .nest(indent: 2, .line <> .text("bar"))
        )
    }
    
    func testUnion() {
        assertPretty(pageWidth: 80, str: "foo bar",
                     doc: .text("foo") <%> .text("bar"))
        assertPretty(pageWidth: 5, str: "foo\nbar",
                     doc: .text("foo") <%> .text("bar"))
    }

    func testLargeDocument() {
        let doc = Array(repeating: Doc.text("foo"), count: 65)
            .fillSep()
        
        assertPretty(pageWidth: 32, str:
            """
            foo foo foo foo foo foo foo foo
            foo foo foo foo foo foo foo foo
            foo foo foo foo foo foo foo foo
            foo foo foo foo foo foo foo foo
            foo foo foo foo foo foo foo foo
            foo foo foo foo foo foo foo foo
            foo foo foo foo foo foo foo foo
            foo foo foo foo foo foo foo foo
            foo
            """, doc: doc)
    }
}
