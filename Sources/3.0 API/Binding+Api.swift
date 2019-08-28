//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public extension Registration {
    func constant<Value>(_ value: Value, tag: String? = nil) -> Binding<Value, Context> {
        return Binding(
            products: [tagged(Value.self, with: tag)],
            dependencies: [],
            factory: { _, _ in value },
            scope: scope,
            arguments: []
        )
    }

    func resultOf<NewInstance>(
        _ call: FunctionCall<NewInstance>,
        as _: NewInstance.Type = NewInstance.self,
        tag: String? = nil
    ) -> Binding<NewInstance, Context> {
        return Binding(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: call.inputs.map { $0.asDependency },
            factory: call.execute,
            scope: scope,
            arguments: .init(types: call.inputs.compactMap { $0.asArgumentDependency })
        )
    }
}

public extension Binding {
    func injectedBy(_ injections: InjectionRequest<Instance> ...) -> Binding<Instance, Context> {
        return updated {
            $0.factory = { resolver, arguments in
                var instance = try self.factory(resolver, arguments)
                try injections.forEach { try $0.execute(resolver, arguments, &instance) }
                return instance
            }
            $0.dependencies += injections.flatMap { $0.inputs }.map { $0.asDependency }
            $0.arguments.types += injections.flatMap { $0.inputs }.compactMap { $0.asArgumentDependency }
        }
    }
}

public extension Binding {
    func toUse<OtherInstance>(_: (Instance) -> OtherInstance, tag: String?) -> Binding<Instance, Context> {
        return updated { $0.products = [tagged(OtherInstance.self, with: tag)] }
    }

    func toUse<OtherInstance>(_ typeCheck: (Instance) -> OtherInstance) -> Binding<Instance, Context> {
        return toUse(typeCheck, tag: nil)
    }

    func alsoUse<OtherInstance>(_: (Instance) -> OtherInstance, tag: String? = nil) -> Binding<Instance, Context> {
        return updated { $0.products.append(tagged(OtherInstance.self, with: tag)) }
    }

    func alsoUse<OtherInstance>(_ typeCheck: (Instance) -> OtherInstance) -> Binding<Instance, Context> {
        return alsoUse(typeCheck, tag: nil)
    }
}

public extension Binding {
    func withProperties(_ update: (inout BindingProperties) -> Void) -> Binding<Instance, Context> {
        return updated { update(&$0.properties) }
    }
}
