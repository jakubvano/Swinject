//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct FuzzyBinding<Instance, Context> {
    var matches: (AnyInstanceRequest) -> Bool
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
}

extension FuzzyBinding: AnyFuzzyBinding {
    public func matches<Type>(_ request: InstanceRequest<Type>) -> Bool {
        return matches(request as AnyInstanceRequest)
    }
}

public extension Registration {
    // TODO: Overloads
    func subtypeFactory<BaseType>(
        for _: BaseType.Type,
        factory: @escaping (BaseType.Type, ContextedResolver<Context>) throws -> BaseType
    ) -> FuzzyBinding<BaseType, Context> {
        return FuzzyBinding<BaseType, Context>(
            matches: { $0.type.type is BaseType.Type },
            dependencies: [],
            factory: { descriptor, resolver, _ in
                guard let type = descriptor.type as? BaseType.Type else { throw TypeMismatch() }
                return try factory(type, resolver)
            },
            arguments: []
        )
    }
}
