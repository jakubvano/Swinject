//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct SubtypeBinding<BaseType> {
    var tag: String?
    var doesTypeMatch: (Any.Type) -> Bool
    var dependencies: [BindingDependency]
    var factory: (TypeDescriptor, Resolver, Arguments) throws -> BaseType
    var properties: BindingProperties = .default
    var scope: AnyScope?
    var arguments: Arguments.Descriptor
    var contextType: Any.Type
}

extension SubtypeBinding: BaseBinding {
    func registryKey(forType type: TypeDescriptor, arguments: Arguments) -> ScopeRegistryKey {
        return ScopeRegistryKey(descriptor: type, arguments: arguments)
    }

    func matches(_ key: BindingKey) -> Bool {
        return key.contextType == contextType // FIXME: optional type, any context
            && key.arguments == arguments
            && key.type.tag == tag
            && doesTypeMatch(key.type.type)
    }
}

public extension SubtypeBinding {
    func withProperties(_ update: (inout BindingProperties) -> Void) -> Self {
        return updated { update(&$0.properties) }
    }
}

public extension Registration {
    // TODO: Overloads
    func subtypeFactory<BaseType>(
        for _: BaseType.Type,
        tag: String? = nil,
        factory: @escaping (BaseType.Type) throws -> BaseType
    ) -> SubtypeBinding<BaseType> {
        return SubtypeBinding<BaseType>(
            tag: tag,
            doesTypeMatch: { $0 is BaseType.Type },
            dependencies: [],
            factory: { descriptor, _, _ in
                guard let type = descriptor.type as? BaseType.Type else { throw TypeMismatch() }
                return try factory(type)
            },
            scope: scope,
            arguments: [],
            contextType: Context.self
        )
    }
}
