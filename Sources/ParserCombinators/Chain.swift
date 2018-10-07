
import Foundation

extension Parser {

    /// Creates a new parser that repeatedly applies this parser interleaved with
    /// the separating parser, until it fails, and returns all parsed values.
    /// The separating parser specifies how the results parsed by this parser should be combined.
    ///
    /// - Parameters:
    ///   - separator: The parser that separates the occurrences of this parser. The result should
    ///                be a function that specifies how the results of this parser should be combined.
    ///   - min: The minumum number of times this parser needs to succeed. If the parser succeeds
    ///          fewer times, the new parser returns a non-fatal failure, i.e. not an error,
    ///          and so backtracking is allowed.
    ///   - max: The maximum number of times this parser is to be applied.
    ///
    public func chainLeft(
        separator: @autoclosure @escaping () -> Parser<(T, T) -> T, Element>,
        min: Int = 0, max: Int? = nil
    )
        -> Parser<T?, Element>
    {
        return ParserCombinators.chainLeft(self,
                                           separator: separator,
                                           min: min,
                                           max: max)
    }
}

/// Creates a new parser that repeatedly applies the given parser interleaved with
/// the separating parser, until it fails, and returns all parsed values.
/// The separating parser specifies how the results parsed by the given parser should be combined.
///
/// - Parameters:
///   - parser: The parser to be applied successively to the input.
///   - separator: The parser that separates the occurrences of the given parser. The result should
///                be a function that specifies how the results of the given parser should be combined.
///   - min: The minumum number of times the given parser needs to succeed. If the parser succeeds
///          fewer times, the new parser returns a non-fatal failure, i.e. not an error,
///          and so backtracking is allowed.
///   - max: The maximum number of times the given parser is to be applied.
///
public func chainLeft<T, Element>(
    _ parser: @autoclosure @escaping () -> Parser<T, Element>,
    separator: @autoclosure @escaping () -> Parser<(T, T) -> T, Element>,
    min: Int = 0,
    max: Int? = nil
)
    -> Parser<T?, Element>
{
    typealias Op = (T, T) -> T

    let lazyParser = Lazy(parser)
    let lazySeparator = Lazy(separator)

    let rest: Parser<[(Op, T)], Element> = lazySeparator.value
        .seq(lazyParser.value)
        .rep(min: Swift.max(0, min - 1),
             max: max.map { $0 - 1})

    let all: Parser<T?, Element> =
        lazyParser.value.seq(rest)
            ^^ { (firstAndRest: (T, [(Op, T)])) -> T in
                let (first, rest) = firstAndRest
                return rest.reduce(first) { result, opAndValue -> T in
                    let (op, value) = opAndValue
                    return op(result, value)
                }
            }

    if min > 0 {
        return all
    }

    return all || success(nil)
}