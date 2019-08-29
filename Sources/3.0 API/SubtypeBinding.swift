//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct SubtypeBinding<Instance, Context> {
    var tag: String?
    var doesTypeMatch: (Any.Type) -> Bool
    var dependencies: [BindingDependency]
    var factory: (TypeDescriptor, ContextedResolver<Context>, Arguments) throws -> Instance
    var properties: BindingProperties = .default
    var scope: AnyScope?
    var arguments: Arguments.Descriptor
}

extension SubtypeBinding: BaseBinding {
    func registryKey(forType type: TypeDescriptor, arguments: Arguments) -> ScopeRegistryKey {
        return ScopeRegistryKey(descriptor: type, arguments: arguments)
    }

    func matches(_ key: BindingKey) -> Bool {
        return key.contextType == Context.self
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
    ) -> SubtypeBinding<BaseType, Context> {
        return SubtypeBinding<BaseType, Context>(
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
