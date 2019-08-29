//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct Binding<Instance> {
    var products: [TypeDescriptor]
    var dependencies: [BindingDependency]
    var factory: (TypeDescriptor, Resolver, Arguments) throws -> Instance
    var properties: BindingProperties = .default
    var scope: AnyScope?
    var arguments: Arguments.Descriptor
    var context: ContextDescriptor
}

extension Binding: BaseBinding, AnyKeyedBinding {
    func registryKey(forType type: TypeDescriptor, arguments: Arguments) -> ScopeRegistryKey {
        return ScopeRegistryKey(descriptor: products.first ?? type, arguments: arguments)
    }

    var keys: [BindingKey] {
        return products.map { BindingKey(type: $0, context: context, arguments: arguments) }
    }
}

public extension Binding {
    func toUse<OtherInstance>(_: (Instance) -> OtherInstance, tag: String?) -> Binding<Instance> {
        return updated { $0.products = [tagged(OtherInstance.self, with: tag)] }
    }

    func toUse<OtherInstance>(_ typeCheck: (Instance) -> OtherInstance) -> Binding<Instance> {
        return toUse(typeCheck, tag: nil)
    }

    func alsoUse<OtherInstance>(_: (Instance) -> OtherInstance, tag: String? = nil) -> Binding<Instance> {
        return updated { $0.products.append(tagged(OtherInstance.self, with: tag)) }
    }

    func alsoUse<OtherInstance>(_ typeCheck: (Instance) -> OtherInstance) -> Binding<Instance> {
        return alsoUse(typeCheck, tag: nil)
    }
}

public extension Binding {
    func injectedBy(_ injections: InjectionRequest<Instance> ...) -> Self {
        return updated {
            $0.factory = { type, resolver, arguments in
                var instance = try self.factory(type, resolver, arguments)
                try injections.forEach { try $0.execute(resolver, arguments, &instance) }
                return instance
            }
            $0.dependencies += injections.flatMap { $0.inputs }.map { $0.asDependency }
            $0.arguments.types += injections.flatMap { $0.inputs }.compactMap { $0.asArgumentDependency }
        }
    }

    func withProperties(_ update: (inout BindingProperties) -> Void) -> Self {
        return updated { update(&$0.properties) }
    }
}

public extension Registration {
    func constant<Value>(_ value: Value, tag: String? = nil) -> Binding<Value> {
        return Binding(
            products: [tagged(Value.self, with: tag)],
            dependencies: [],
            factory: { _, _, _ in value },
            scope: scope,
            arguments: [],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func resultOf<NewInstance>(
        _ call: FunctionCall<NewInstance>,
        as _: NewInstance.Type = NewInstance.self,
        tag: String? = nil
    ) -> Binding<NewInstance> {
        return Binding(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: call.inputs.map { $0.asDependency },
            factory: { try call.execute($1, $2) },
            scope: scope,
            arguments: .init(types: call.inputs.compactMap { $0.asArgumentDependency }),
            context: ContextDescriptor(type: Context.self)
        )
    }
}

// swiftlint:disable line_length
// swiftlint:disable identifier_name
// sourcery:inline:BindingFactoryApi
public extension Registration {
    func factory<NewInstance>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping () throws -> NewInstance) -> Binding<NewInstance> {
        return Binding<NewInstance>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, _, _ in try factory() },
            scope: scope,
            arguments: [],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func factory<NewInstance>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>) throws -> NewInstance) -> Binding<NewInstance> {
        return Binding<NewInstance>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, r, _ in try factory(r.contexted()) },
            scope: scope,
            arguments: [],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func factory<NewInstance, Arg1>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1) throws -> NewInstance) -> Binding<NewInstance> {
        return Binding<NewInstance>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, r, a in try factory(r.contexted(), a.arg(0)) },
            scope: scope,
            arguments: [Arg1.self],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func factory<NewInstance, Arg1, Arg2>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2) throws -> NewInstance) -> Binding<NewInstance> {
        return Binding<NewInstance>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, r, a in try factory(r.contexted(), a.arg(0), a.arg(1)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func factory<NewInstance, Arg1, Arg2, Arg3>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2, Arg3) throws -> NewInstance) -> Binding<NewInstance> {
        return Binding<NewInstance>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, r, a in try factory(r.contexted(), a.arg(0), a.arg(1), a.arg(2)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self, Arg3.self],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func factory<NewInstance, Arg1, Arg2, Arg3, Arg4>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2, Arg3, Arg4) throws -> NewInstance) -> Binding<NewInstance> {
        return Binding<NewInstance>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, r, a in try factory(r.contexted(), a.arg(0), a.arg(1), a.arg(2), a.arg(3)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self, Arg3.self, Arg4.self],
            context: ContextDescriptor(type: Context.self)
        )
    }

    func factory<NewInstance, Arg1, Arg2, Arg3, Arg4, Arg5>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2, Arg3, Arg4, Arg5) throws -> NewInstance) -> Binding<NewInstance> {
        return Binding<NewInstance>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, r, a in try factory(r.contexted(), a.arg(0), a.arg(1), a.arg(2), a.arg(3), a.arg(4)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self, Arg3.self, Arg4.self, Arg5.self],
            context: ContextDescriptor(type: Context.self)
        )
    }
}

// sourcery:end
