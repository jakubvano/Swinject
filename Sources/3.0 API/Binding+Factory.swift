//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

// swiftlint:disable line_length
// swiftlint:disable identifier_name
// sourcery:inline:BindingFactoryApi
public extension Registration {
    func factory<NewInstance>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping () throws -> NewInstance) -> Binding<NewInstance, Context> {
        return Binding<NewInstance, Context>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { _, _ in try factory() },
            scope: scope,
            arguments: []
        )
    }

    func factory<NewInstance>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>) throws -> NewInstance) -> Binding<NewInstance, Context> {
        return Binding<NewInstance, Context>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { r, _ in try factory(r) },
            scope: scope,
            arguments: []
        )
    }

    func factory<NewInstance, Arg1>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1) throws -> NewInstance) -> Binding<NewInstance, Context> {
        return Binding<NewInstance, Context>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { r, a in try factory(r, a.arg(0)) },
            scope: scope,
            arguments: [Arg1.self]
        )
    }

    func factory<NewInstance, Arg1, Arg2>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2) throws -> NewInstance) -> Binding<NewInstance, Context> {
        return Binding<NewInstance, Context>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { r, a in try factory(r, a.arg(0), a.arg(1)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self]
        )
    }

    func factory<NewInstance, Arg1, Arg2, Arg3>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2, Arg3) throws -> NewInstance) -> Binding<NewInstance, Context> {
        return Binding<NewInstance, Context>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { r, a in try factory(r, a.arg(0), a.arg(1), a.arg(2)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self, Arg3.self]
        )
    }

    func factory<NewInstance, Arg1, Arg2, Arg3, Arg4>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2, Arg3, Arg4) throws -> NewInstance) -> Binding<NewInstance, Context> {
        return Binding<NewInstance, Context>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { r, a in try factory(r, a.arg(0), a.arg(1), a.arg(2), a.arg(3)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self, Arg3.self, Arg4.self]
        )
    }

    func factory<NewInstance, Arg1, Arg2, Arg3, Arg4, Arg5>(for _: NewInstance.Type = NewInstance.self, tag: String? = nil, factory: @escaping (ContextedResolver<Context>, Arg1, Arg2, Arg3, Arg4, Arg5) throws -> NewInstance) -> Binding<NewInstance, Context> {
        return Binding<NewInstance, Context>(
            products: [tagged(NewInstance.self, with: tag)],
            dependencies: [],
            factory: { r, a in try factory(r, a.arg(0), a.arg(1), a.arg(2), a.arg(3), a.arg(4)) },
            scope: scope,
            arguments: [Arg1.self, Arg2.self, Arg3.self, Arg4.self, Arg5.self]
        )
    }
}

// sourcery:end
