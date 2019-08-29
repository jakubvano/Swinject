//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

protocol AnyContextTranslator: SwinjectEntry {
    var source: ContextDescriptor { get }
    var target: ContextDescriptor { get }
    func translate(_ context: Any) throws -> Any
}

public struct ContextTranslator<Source, Target>: AnyContextTranslator {
    let source = ContextDescriptor(type: Source.self)
    let target = ContextDescriptor(type: Target.self)
    let translation: (Source) -> Target

    func translate(_ context: Any) throws -> Any {
        guard let context = context as? Source else { throw SwinjectError() }
        return translation(context)
    }
}

struct IdentityTranslator: AnyContextTranslator {
    let source: ContextDescriptor
    let target: ContextDescriptor

    init(for context: ContextDescriptor) {
        source = context
        target = context
    }

    func translate(_ context: Any) throws -> Any { return context }
}

struct ToAnyTranslator: AnyContextTranslator {
    let source: ContextDescriptor
    let target = ContextDescriptor(type: Any.self)

    init(for source: ContextDescriptor) {
        self.source = source
    }

    func translate(_ context: Any) throws -> Any { return context }
}

public func registerContextTranslator<Source, Target>(
    from _: Source.Type = Source.self,
    to _: Target.Type = Target.self,
    using translation: @escaping (Source) -> Target
) -> ContextTranslator<Source, Target> {
    return ContextTranslator(translation: translation)
}
