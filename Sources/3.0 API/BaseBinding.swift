//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct BindingProperties {
    public var overrides: Bool
    public var reference: ReferenceMaker<Any>

    static let `default` = BindingProperties(overrides: false, reference: strongRef)
}

protocol BaseBinding: AnyBinding {
    associatedtype Instance

    var factory: (TypeDescriptor, Resolver, Arguments) throws -> Instance { get set }
    var properties: BindingProperties { get set }
    var scope: AnyScope? { get }
    var context: ContextDescriptor { get }

    func registryKey(forType type: TypeDescriptor, arguments: Arguments) -> ScopeRegistryKey
}

extension BaseBinding {
    var overrides: Bool { return properties.overrides }

    func makeInstance(type: TypeDescriptor, resolver: Resolver, arguments: Arguments) throws -> Any {
        if let scope = scope {
            return try scopedInstance(type: type, resolver: resolver, scope: scope, arguments: arguments)
        } else {
            return try factory(type, resolver, arguments)
        }
    }

    private func scopedInstance(
        type: TypeDescriptor, resolver: Resolver, scope: AnyScope, arguments: Arguments
    ) throws -> Any {
        return try scope
            .registry(for: resolver.context(as: context.type))
            .instance(for: registryKey(forType: type, arguments: arguments)) {
                try properties.reference(factory(type, resolver, arguments))
            }
    }
}

extension BaseBinding {
    func updated(_ update: (inout Self) -> Void) -> Self {
        var copy = self
        update(&copy)
        return copy
    }
}
