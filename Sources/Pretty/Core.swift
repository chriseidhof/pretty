public protocol El {
    associatedtype Width: AdditiveArithmetic & Comparable = Int
    var width: Width { get }
    static var space: Self { get }
    init()
    
    static var newline: Self { get }
    static func indent(width: Width) -> Self
    mutating func append(contentsOf: Self)
}



/// A document that can be laid out (later) with a specific width.
indirect public enum Doc<A: El & Equatable>: Equatable {
    case empty
    case seq(Doc, Doc)
    case nest(indent: A.Width, Doc)
    case _text(A, A.Width)
    case line
    case choice(Doc, Doc)
    
    ///  Atomic text.
    ///
    ///  This should not contain newlines.
    ///
    /// - Parameter value: the text
    /// - Returns: a document containing the text
    static public func text(_ value: A) -> Doc<A> {
        return ._text(value, value.width)
    }
    
    public func nest(indent: A.Width) -> Self {
        .nest(indent: indent, self)
    }
}

extension Doc {
    /// Replace all the newlines in a document with spaces
    public var flatten: Doc<A> {
        switch self {
        case .empty:
            return .empty
        case let .seq(l, r):
            return .seq(l.flatten, r.flatten)
        case let .nest(indent, doc):
            return .nest(indent: indent, doc.flatten)
        case ._text:
            return self
        case .line:
            return .text(.space)
        case .choice(let l, _):
            return l.flatten
        }
    }
    
    /// Choice between the flattened version of self (if it fits) or the regular version with newlines.
    public var grouped: Doc {
        return .choice(flatten, self)
    }
}

extension Doc {
    func best(width: A.Width, column: A.Width = .zero) -> SimpleDoc<A> {
        return be(width: width, column: column, [(.zero, self)])
    }
}

indirect enum SimpleDoc<A: El> {
    case empty
    case text(A, SimpleDoc<A>)
    case line(indent: A.Width, () -> SimpleDoc<A>)
}

extension SimpleDoc {
    func fits(width: A.Width, column: A.Width) -> Bool {
        if column > width { return false }
        switch self {
        case .empty, .line: return true
        case let .text(t, cont):
            return cont.fits(width: width, column: column + t.width)
        }
    }
}

func be<A, S>(width: A.Width, column: A.Width, _ pairs: S) -> SimpleDoc<A> where S: Collection, S.Element == (A.Width, Doc<A>){
    guard let (i,el) = pairs.first else { return .empty }
    let remainder = pairs.dropFirst()
    switch el {
    case .empty:
        return be(width: width, column: column, remainder)
    case let .seq(l,r):
        return be(width: width, column: column, [(i,l), (i,r)] +  remainder)
    case let .nest(indent: j, doc):
        return be(width: width, column: column, [(i+j, doc)] +  remainder)
    case let ._text(t, w):
        return .text(t, be(width: width, column: column + w, remainder))
    case .line:
        return .line(indent: i, { be(width: width, column: i, remainder) })
    case let .choice(l, r):
        let l1 = be(width: width, column: column, [(i,l)] + remainder)
        if l1.fits(width: width, column: column) {
            return l1
        } else {
            return be(width: width, column: column, [(i,r)] + remainder)
        }
    }
}

// Fixed-width strings (each character counts as a width of 1).
extension String: El {
    public var width: Int { return count }
    public static let space = " "
    public static let newline = "\n"
    public static func indent(width: Int) -> String {
        return String(repeating: " ", count: width)
    }
}

extension SimpleDoc {
    public var layout: A {
        var result = A()
        var current = self
        while true {
            switch current {
            case .empty: return result
            case let .text(t, cont):
                result.append(contentsOf: t)
                current = cont
            case let .line(indent: i, cont):
                result.append(contentsOf: .newline)
                result.append(contentsOf: A.indent(width: i))
                current = cont()
            }
        }
    }
}

infix operator <>: AdditionPrecedence

extension Doc {
    /// A space
    public static var space: Doc { return .text(.space) }
    
    /// Horizontally concatenate two documents
    public static func <>(lhs: Doc, rhs: Doc) -> Doc {
        return .seq(lhs, rhs)
    }
    
    /// Render the final document with a horizontal constraint of `width`
    public func renderPretty(width: A.Width) -> A {
        return best(width: width, column: .zero).layout
    }
}

// Combinators

infix operator </>: AdditionPrecedence
infix operator <+>: AdditionPrecedence
infix operator <%>: AdditionPrecedence

// This should be Collection where Element == Doc<A>....
extension Collection where Element == Doc<String> {
    /// Concats all horizontally until end of page
    /// then puts a line and repeats
    public func fillSep() -> Doc<String> {
        return reduce(<%>)
    }
    
    /// Returns an empty document if `self.isEmpty`, otherwise reduces self.
    public func reduce(_ combine: (Doc<String>, Doc<String>) -> Doc<String>) -> Doc<String> {
        guard let f = first else { return .empty }
        return dropFirst().reduce(f, combine)
    }
}

extension Doc {
    /// Horizontally concatenate `x` and `y` with a space in between
    public static func <+>(x: Doc, y: Doc) -> Doc {
        return x <> space <> y
    }
    
    /// Concatenate `x` and `y` with a newline in between
    public static func </>(x: Doc, y: Doc) -> Doc {
        return x <> .line <> y
    }
    
    /// Try to horizontally concatenate and otherwise insert a newline
    public static var softline: Doc {
        return Doc.line.grouped
    }
    
    /// Put `x` and `y` horizontally next to each other, otherwise insert a newline.
    public static func <%>(x: Doc, y: Doc) -> Doc {
        return x <> softline <> y
    }
}

