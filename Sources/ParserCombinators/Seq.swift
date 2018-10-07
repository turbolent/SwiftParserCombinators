
extension Parser {

    private func seq<U, V>(_ next: Lazy<Parser<U, Element>>, f: @escaping (T, U) -> V) -> Parser<V, Element> {
        return flatMap { firstResult in
            next.value.map { secondResult in
                f(firstResult, secondResult)
            }
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both in a tuple. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<(T, U), Element>
    {
        return seqTuple(next)
    }

    // Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both in a tuple. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seqTuple<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<(T, U), Element>
    {
        return seq(Lazy(next)) { ($0, $1) }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both sequenced. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U: Sequenceable>(_ next: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<U, Element>
        where U.Element == T
    {
        return seq(Lazy(next)) {
            U.empty
                .sequence(next: $0)
                .sequence(next: $1)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both sequenced. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U: Sequenceable>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<U, Element>
        where U.Element == T
    {
        return seq(Lazy(next)) {
            // NOTE: order
            $1.sequence(previous: $0)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both sequenced. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U: AnySequenceable>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<U, Element>
    {
        return seq(Lazy(next)) {
            // NOTE: order
            $1.sequence(previous: $0)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the result of the next parser, i.e., the result of this parser is ignored. The next parser
    /// is applied to the input left over by this parser. The new parser succeeds if (and only if)
    /// both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seqIgnoreLeft<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<U, Element>
    {
        let lazyNext = Lazy(next)
        return flatMap { _ in lazyNext.value }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the result of this parser, i.e., the result of the next parser is ignored. The next parser
    /// is applied to the input left over by this parser. The new parser succeeds if (and only if)
    /// both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seqIgnoreRight<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) { (left, _) in left }
    }
}

extension Parser where T: Sequenceable {

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both sequenced. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq(_ next: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) {
            $0.sequence(other: $1)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both sequenced. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<T, Element>
        where T.Element == U
    {
        return seq(Lazy(next)) {
            $0.sequence(next: $1)
        }
    }
}

extension Parser where T: AnySequenceable {

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both sequenced. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq(_ next: @autoclosure @escaping () -> Parser<T, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) {
            $0.sequence(other: $1)
        }
    }

    /// Creates a new parser that applies this parser and the next parser in sequence, and returns
    /// the results of both sequenced. The next parser is applied to the input left over by this parser.
    /// The new parser succeeds if (and only if) both parsers succeed.
    ///
    /// - Note: The next parser is only applied if this parser succeeds.
    ///
    /// - Parameter next: The parser to be applied after this parser suceeded.
    ///
    public func seq<U>(_ next: @autoclosure @escaping () -> Parser<U, Element>)
        -> Parser<T, Element>
    {
        return seq(Lazy(next)) {
            $0.sequence(next: $1)
        }
    }
}


infix operator ~: ApplicativePrecedence
infix operator ~~: ApplicativePrecedence

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U, Element>(first: Parser<T, Element>,
                              second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<(T, U), Element>
{
    return first.seq(second)
}

// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~~ <T, U, Element>(first: Parser<T, Element>,
                               second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<(T, U), Element>
{
    return first.seqTuple(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both sequenced. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T: Sequenceable, Element>(first: Parser<T, Element>,
                                         second: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    return first.seq(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both sequenced. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T: AnySequenceable, Element>(first: Parser<T, Element>,
                                            second: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<T, Element>
{
    return first.seq(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both sequenced. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///

public func ~ <T: Sequenceable, U, Element>(first: Parser<T, Element>,
                                            second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<T, Element>
    where T.Element == U
{
    return first.seq(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both sequenced. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///

public func ~ <T: AnySequenceable, U, Element>(first: Parser<T, Element>,
                                               second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<T, Element>
{
    return first.seq(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both sequenced. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U: Sequenceable, Element>(first: Parser<T, Element>,
                                            second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<U, Element>
    where U.Element == T
{
    return first.seq(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both sequenced. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U: AnySequenceable, Element>(first: Parser<T, Element>,
                                               second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<U, Element>
{
    return first.seq(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both sequenced. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U: Sequenceable, Element>(first: Parser<T, Element>,
                                            second: @autoclosure @escaping () -> Parser<T, Element>)
    -> Parser<U, Element>
    where U.Element == T
{
    return first.seq(second)
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U, V, Element>(first: Parser<(T, U), Element>,
                                 second: @autoclosure @escaping () -> Parser<V, Element>)
    -> Parser<(T, U, V), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~~ <T, U, V, Element>(first: Parser<(T, U), Element>,
                                  second: @autoclosure @escaping () -> Parser<V, Element>)
    -> Parser<(T, U, V), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U, V, W, Element>(first: Parser<(T, U, V), Element>,
                                    second: @autoclosure @escaping () -> Parser<W, Element>)
    -> Parser<(T, U, V, W), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~~ <T, U, V, W, Element>(first: Parser<(T, U, V), Element>,
                                     second: @autoclosure @escaping () -> Parser<W, Element>)
    -> Parser<(T, U, V, W), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U, V, W, X, Element>(first: Parser<(T, U, V, W), Element>,
                                       second: @autoclosure @escaping () -> Parser<X, Element>)
    -> Parser<(T, U, V, W, X), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~~ <T, U, V, W, X, Element>(first: Parser<(T, U, V, W), Element>,
                                        second: @autoclosure @escaping () -> Parser<X, Element>)
    -> Parser<(T, U, V, W, X), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U, V, W, X, Y, Element>(first: Parser<(T, U, V, W, X), Element>,
                                          second: @autoclosure @escaping () -> Parser<Y, Element>)
    -> Parser<(T, U, V, W, X, Y), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~~ <T, U, V, W, X, Y, Element>(first: Parser<(T, U, V, W, X), Element>,
                                           second: @autoclosure @escaping () -> Parser<Y, Element>)
    -> Parser<(T, U, V, W, X, Y), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~ <T, U, V, W, X, Y, Z, Element>(first: Parser<(T, U, V, W, X, Y), Element>,
                                             second: @autoclosure @escaping () -> Parser<Z, Element>)
    -> Parser<(T, U, V, W, X, Y, Z), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.0.5, $0.1) }
}

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the results of both in a tuple. The second parser is applied to the input left over by the first parser.
/// The new parser succeeds if (and only if) both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~~ <T, U, V, W, X, Y, Z, Element>(first: Parser<(T, U, V, W, X, Y), Element>,
                                              second: @autoclosure @escaping () -> Parser<Z, Element>)
    -> Parser<(T, U, V, W, X, Y, Z), Element>
{
    return first.seqTuple(second).map { ($0.0.0, $0.0.1, $0.0.2, $0.0.3, $0.0.4, $0.0.5, $0.1) }
}

// NOTE: actual defintition would be, but already defined in the standard definition as a workaround,
// see https://github.com/apple/swift/blob/48308411393e730cf3cb21d353a9be31045c47e4/stdlib/public/core/Policy.swift#L705
//infix operator ~> : ApplicativeSequencePrecedence

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the result of the second parser, i.e., the result of the first parser is ignored. The second parser
/// is applied to the input left over by the first parser. The new parser succeeds if (and only if)
/// both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func ~> <T, U, Element>(first: Parser<T, Element>,
                               second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<U, Element>
{
    return first.seqIgnoreLeft(second)
}

infix operator <~ : ApplicativeSequencePrecedence

/// Creates a new parser that applies the first parser and the second parser in sequence, and returns
/// the result of the first parser, i.e., the result of the second parser is ignored. The second parser
/// is applied to the input left over by the first parser. The new parser succeeds if (and only if)
/// both parsers succeed.
///
/// - Note: The second parser is only applied if the first parser succeeds.
///
/// - Parameters:
///   - first: The parser to be applied first.
///   - second: The parser to be applied after the first parser suceeded.
///
public func <~ <T, U, Element>(first: Parser<T, Element>,
                               second: @autoclosure @escaping () -> Parser<U, Element>)
    -> Parser<T, Element>
{
    return first.seqIgnoreRight(second)
}