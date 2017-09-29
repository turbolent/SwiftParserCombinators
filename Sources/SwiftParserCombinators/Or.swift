
extension Parser {

    // NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
    public func or<U>(_ next: @autoclosure @escaping () -> Parser<U, Input>) -> Parser<U, Input> {
        let lazyNext = Lazy(next)
        return Parser<U, Input> { input in
            self.step(input).flatMap { $0.append(lazyNext.value.step(input)) }
        }
    }
}


// NOTE: unfortunately it is not possible in Swift to constrain U to be a supertype of T
public func || <T, U, Input>(lhs: @autoclosure () -> Parser<T, Input>,
                             rhs: @autoclosure @escaping () -> Parser<U, Input>)
    -> Parser<U, Input>
{
    return lhs().or(rhs())
}

