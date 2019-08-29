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
    var context: ContextDescriptor
}

extension SubtypeBinding: BaseBinding {
    func registryKey(forType type: TypeDescriptor, arguments: Arguments) -> ScopeRegistryKey {
        return ScopeRegistryKey(descriptor: type, arguments: arguments)
    }

    func matches(_ key: BindingKey) -> Bool {
        return key.context == context
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

public extension SubtypeBinding {
    func toUseWhen(_ condition: @escaping (Any.Type) -> Bool) -> SubtypeBinding<BaseType> {
        return updated { $0.doesTypeMatch = { self.doesTypeMatch($0) && condition($0) } }
    }
}

public extension Registration {
    // TODO: Overloads
    func classFactory<Class>(
        for _: Class.Type,
        tag: String? = nil,
        factory: @escaping (Class.Type) throws -> Class
    ) -> SubtypeBinding<Class> where Class: AnyObject {
        return SubtypeBinding<Class>(
            tag: tag,
            doesTypeMatch: { $0 is Class.Type },
            dependencies: [],
            factory: { descriptor, _, _ in
                guard let type = descriptor.type as? Class.Type else { throw TypeMismatch() }
                return try factory(type)
            },
            scope: scope,
            arguments: [],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func anyTypeFactory(tag _: String? = nil, factory: @escaping (Any.Type) throws -> Any) -> SubtypeBinding<Any> {
        return SubtypeBinding<Any>(
            tag: nil,
            doesTypeMatch: { _ in true },
            dependencies: [],
            factory: { descriptor, _, _ in try factory(descriptor.type) },
            scope: scope,
            arguments: [],
            context: ContextDescriptor(type: Context.self)
        )
    }
}
