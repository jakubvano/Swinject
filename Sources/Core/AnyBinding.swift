//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct BindingKey: Hashable {
    let type: TypeDescriptor
    let context: ContextDescriptor
    let arguments: Arguments.Descriptor
}

public enum BindingDependency {
    case instance(InstanceRequestDescriptor)
    case argument(Any.Type)
    case context(Any.Type)
}

protocol AnyBinding: SwinjectEntry {
    var dependencies: [BindingDependency] { get }
    var overrides: Bool { get }
    func matches(_ key: BindingKey) -> Bool
    func makeInstance(type: TypeDescriptor, resolver: Resolver, arguments: Arguments) throws -> Any
}

protocol AnyKeyedBinding: AnyBinding {
    var keys: [BindingKey] { get }
}

extension AnyKeyedBinding {
    func matches(_ key: BindingKey) -> Bool {
        return keys.contains(key)
    }
}
