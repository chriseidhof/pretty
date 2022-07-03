public protocol El {
    associatedtype Width: AdditiveArithmetic & Comparable = Int
    var width: Width { get }
    static var space: Self { get }
    init()
    
    static var newline: Self { get }
    static func indent(width: Width) -> Self
    mutating func append(contentsOf: Self)
}



indirect public enum Doc<A: El> {
    case empty
    case seq(Doc, Doc)
    case nest(indent: A.Width, Doc)
    case _text(A, A.Width)
    case line
    case choice(Doc, Doc)
    
    static public func text(_ value: A) -> Doc<A> {
        return ._text(value, value.width)
    }
}

extension Doc {
    var flatten: Doc<A> {
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
    
    var grouped: Doc {
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
    public static var space: Doc { return .text(.space) }
    public static func <>(lhs: Doc, rhs: Doc) -> Doc {
        return .seq(lhs, rhs)
    }
    
    public func renderPretty(width: A.Width) -> A {
        return best(width: width, column: .zero).layout
    }
}

// Combinators

infix operator <+>: AdditionPrecedence
infix operator <%>: AdditionPrecedence

// This should be Collection where Element == Doc<A>....
extension Collection where Element == Doc<String> {
    /// Concats all horizontally until end of page
    /// then puts a line and repeats
    public func fillSep() -> Doc<String> {
        return reduce(<%>)
    }
    
    func reduce(_ combine: (Doc<String>, Doc<String>) -> Doc<String>) -> Doc<String> {
        if isEmpty { return .empty }
        return dropFirst().reduce(first!, combine)
    }
    
}

extension Doc {
    public static func <+>(x: Doc, y: Doc) -> Doc {
        return x <> space <> y
    }
    
    public static var softline: Doc {
        return Doc.line.grouped
    }
    
    public static func <%>(x: Doc, y: Doc) -> Doc {
        return x <> softline <> y
    }
}
