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
    associatedtype Context

    var factory: (TypeDescriptor, ContextedResolver<Context>, Arguments) throws -> Instance { get set }
    var properties: BindingProperties { get set }
    var scope: AnyScope? { get }

    func registryKey(forType type: TypeDescriptor, arguments: Arguments) -> ScopeRegistryKey
}

extension BaseBinding {
    var overrides: Bool { return properties.overrides }

    func makeInstance(type: TypeDescriptor, resolver: Resolver, arguments: Arguments) throws -> Any {
        if let scope = scope {
            return try scopedInstance(type: type, resolver: resolver, scope: scope, arguments: arguments)
        } else {
            return try simpleInstance(type: type, resolver: resolver, arguments: arguments)
        }
    }

    private func scopedInstance(
        type: TypeDescriptor, resolver: Resolver, scope: AnyScope, arguments: Arguments
    ) throws -> Any {
        return try scope
            .registry(for: resolver.context(as: Context.self))
            .instance(for: registryKey(forType: type, arguments: arguments)) {
                try properties.reference(simpleInstance(type: type, resolver: resolver, arguments: arguments))
            }
    }

    private func simpleInstance(type: TypeDescriptor, resolver: Resolver, arguments: Arguments) throws -> Any {
        return try factory(type, resolver.contexted(), arguments)
    }
}

extension BaseBinding {
    func updated(_ update: (inout Self) -> Void) -> Self {
        var copy = self
        update(&copy)
        return copy
    }
}
