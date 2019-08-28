//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

public struct BindingKey: Hashable {
    let type: TypeDescriptor
    let contextType: Any.Type
    let arguments: Arguments.Descriptor

    init(type: TypeDescriptor, contextType: Any.Type, arguments: Arguments.Descriptor) {
        self.type = type
        self.contextType = unwrapOptionals(contextType)
        self.arguments = arguments
    }

    public func hash(into hasher: inout Hasher) {
        type.hash(into: &hasher)
        ObjectIdentifier(contextType).hash(into: &hasher)
        arguments.hash(into: &hasher)
    }

    public static func == (lhs: BindingKey, rhs: BindingKey) -> Bool {
        return lhs.type == rhs.type
            && lhs.contextType == rhs.contextType
            && lhs.arguments == rhs.arguments
    }
}

extension BindingKey {
    func matches(contextType: Any.Type) -> Bool {
        return self.contextType == Any.self || self.contextType == unwrapOptionals(contextType)
    }
}

public enum BindingDependency {
    case instance(InstanceRequestDescriptor)
    case argument(Any.Type)
    case context(Any.Type)
}

public protocol AnyBinding: SwinjectEntry {
    var dependencies: [BindingDependency] { get }
    var overrides: Bool { get }
    func matches(_ key: BindingKey) -> Bool
    func makeInstance(type: TypeDescriptor, resolver: Resolver, arguments: Arguments) throws -> Any
}

protocol AnyKeyedBinding: AnyBinding {
    var keys: [BindingKey] { get }
}

extension AnyKeyedBinding {
    public func matches(_ key: BindingKey) -> Bool {
        return keys.contains(key)
    }
}
