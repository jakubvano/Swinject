//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct Swinject {
    struct Properties {
        let allowsSilentOverride: Bool
        let detectsCircularDependencies: Bool
    }

    let tree: SwinjectTree
    let container: SwinjectContainer
    let anyContext: Any
    let contextDescriptor: ContextDescriptor
    let stack: [AnyInstanceRequest]
    let properties: Properties
}

extension Swinject: Resolver {
    public func resolve<Type>(_ request: InstanceRequest<Type>) throws -> Type {
        let binding: AnyBinding
        do {
            binding = try container.findBinding(for: request.descriptor, on: contextDescriptor)
        } catch let error as NoBinding {
            if let custom = customResolve(request) { return custom }
            throw error
        }
        return try tracking(request).makeInstance(of: request.type, from: binding, with: request.arguments)
    }

    public func on<Context>(_ context: Context) -> Resolver {
        return with(context: context, contextDescriptor: ContextDescriptor(type: Context.self))
    }

    public func context(as resultType: Any.Type) throws -> Any {
        return try container.allTranslators(on: contextDescriptor)
            .filter { $0.source == contextDescriptor && $0.target == ContextDescriptor(type: resultType) }
            .compactMap { try $0.translate(anyContext) }
            .first ?? { throw NoContextTranslator() }()
    }
}

extension Swinject {
    private func customResolve<Type>(_ request: InstanceRequest<Type>) -> Type? {
        guard let custom = Type.self as? CustomResolvable.Type else { return nil }
        guard container.hasBinding(for: request.descriptor, on: contextDescriptor) else { return nil }
        return custom.init(
            resolver: custom.delaysResolution ? with(stack: []) : self,
            request: request
        ) as? Type
    }

    private func tracking(_ request: AnyInstanceRequest) throws -> Swinject {
        guard properties.detectsCircularDependencies else { return self }
        guard !stack.contains(where: { request.matches($0) }) else { throw CircularDependency() }
        return with(stack: stack + [request])
    }

    private func makeInstance<Type>(
        of type: TypeDescriptor, from binding: AnyBinding, with arguments: Arguments
    ) throws -> Type {
        return try binding.makeInstance(type: type, resolver: self, arguments: arguments) as? Type
            ?? { throw SwinjectError() }()
    }
}

extension Swinject {
    init(tree: SwinjectTree, properties: Properties) {
        self.init(
            tree: tree,
            container: SwinjectContainer.Builder(tree: tree, properties: properties).makeContainer(),
            anyContext: (),
            contextDescriptor: .anyContext,
            stack: [],
            properties: properties
        )
    }

    func with(
        context: Any? = nil,
        contextDescriptor: ContextDescriptor? = nil,
        stack: [AnyInstanceRequest]? = nil
    ) -> Swinject {
        return Swinject(
            tree: tree,
            container: container,
            anyContext: context ?? anyContext,
            contextDescriptor: contextDescriptor ?? self.contextDescriptor,
            stack: stack ?? self.stack,
            properties: properties
        )
    }
}
