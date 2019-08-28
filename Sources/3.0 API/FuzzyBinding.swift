//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct FuzzyBinding<Instance, Context> {
    public let contextType: Any.Type = Context.self
    var tag: String?
    var doesTypeMatch: (Any.Type) -> Bool
    public var dependencies: [BindingDependency]
    var factory: (TypeDescriptor, ContextedResolver<Context>, Arguments) throws -> Instance
    var properties: BindingProperties = .default
    var scope: AnyScope?
    var arguments: Arguments.Descriptor
}

extension FuzzyBinding: Binding {
    func registryKey(forType type: TypeDescriptor, arguments: Arguments) -> ScopeRegistryKey {
        return ScopeRegistryKey(descriptor: type, arguments: arguments)
    }

    public func matches(_ key: BindingKey) -> Bool {
        return key.contextType == contextType
            && key.arguments == arguments
            && key.type.tag == tag
            && doesTypeMatch(key.type.type)
    }
}

public extension Registration {
    // TODO: Overloads
    func subtypeFactory<BaseType>(
        for _: BaseType.Type,
        tag: String? = nil,
        factory: @escaping (BaseType.Type) throws -> BaseType
    ) -> FuzzyBinding<BaseType, Context> {
        return FuzzyBinding<BaseType, Context>(
            tag: tag,
            doesTypeMatch: { $0 is BaseType.Type },
            dependencies: [],
            factory: { descriptor, _, _ in
                guard let type = descriptor.type as? BaseType.Type else { throw TypeMismatch() }
                return try factory(type)
            },
            scope: scope,
            arguments: []
        )
    }
}
