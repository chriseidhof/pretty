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
        assertPretty(pageWidth: 80, str: "some code", doc: "some" <> .space <> "code")
    }
    
    func testNest() {
        assertPretty(
            pageWidth: 80,
            str: "foo bar",
            doc: "foo" <+> .text("bar").indent(2)
        )

        assertPretty(
            pageWidth: 80,
            str: "foo\n  bar",
            doc: .text("foo") <> (.line <> "bar").indent(2)
        )
    }
    
    func testUnion() {
        assertPretty(pageWidth: 80, str: "foo bar",
                     doc: "foo" <%> "bar")
        assertPretty(pageWidth: 5, str: "foo\nbar",
                     doc: "foo" <%> "bar")
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
