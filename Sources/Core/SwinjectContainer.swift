//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

struct SwinjectContainer {
    let keyedBindings: [BindingKey: AnyBinding]
    let nonKeyedBindings: [AnyBinding]
    let translators: [AnyContextTranslator]
}

extension SwinjectContainer {
    func checkDependencies() throws {
        try keyedBindings.values
            .flatMap { $0.dependencies }
            .compactMap { $0.asInstanceRequest }
            .forEach {
                if !hasBinding(for: $0, on: .anyContext) { throw MissingDependency() }
            }
    }
}

extension SwinjectContainer {
    func hasBinding(for request: InstanceRequestDescriptor, on context: ContextDescriptor) -> Bool {
        if let custom = request.type.type as? CustomResolvable.Type {
            return custom.requiredRequest(for: request).map { hasBinding(for: $0, on: context) } ?? true
        } else {
            return (try? findBinding(for: request, on: context)) != nil
        }
    }

    func findBinding(for request: InstanceRequestDescriptor, on context: ContextDescriptor) throws -> AnyBinding {
        let bindings = findBindings(for: request, on: context)
        if bindings.isEmpty { throw NoBinding() }
        if bindings.count > 1 { throw MultipleBindings() }
        return bindings[0]
    }

    func allTranslators(on context: ContextDescriptor) -> [AnyContextTranslator] {
        return translators.filter { $0.source == context } + defaultTranslators(on: context)
    }

    private func findBindings(for request: InstanceRequestDescriptor, on context: ContextDescriptor) -> [AnyBinding] {
        let keyed = translatableKeys(for: request, on: context).compactMap { keyedBindings[$0] }
        if !keyed.isEmpty {
            return keyed
        } else {
            return translatableKeys(for: request, on: context).flatMap { key in
                nonKeyedBindings.filter { $0.matches(key) }
            }
        }
    }

    private func defaultTranslators(on context: ContextDescriptor) -> [AnyContextTranslator] {
        return [IdentityTranslator(for: context)]
            + (context == .anyContext ? [] : [ToAnyTranslator(for: context)])
    }

    private func translatableKeys(
        for request: InstanceRequestDescriptor, on context: ContextDescriptor
    ) -> [BindingKey] {
        return allTranslators(on: context).map { request.key(on: $0.target) }
    }
}

private extension BindingDependency {
    var asInstanceRequest: InstanceRequestDescriptor? {
        if case let .instance(descriptor) = self { return descriptor } else { return nil }
    }
}
