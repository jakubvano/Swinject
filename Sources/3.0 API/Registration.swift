//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct Registration<Context> {
    let scope: AnyScope?
}

public func register<Context>(inContextOf _: Context.Type) -> Registration<Context> {
    return Registration(scope: nil)
}

public func register() -> Registration<Any> {
    return register(inContextOf: Any.self)
}

public func registerSingle<AScope: Scope>(in scope: AScope) -> Registration<AScope.Context> {
    return Registration(scope: scope)
}

public func registerSingle() -> Registration<UnboundScope.Context> {
    return registerSingle(in: UnboundScope.root)
}
