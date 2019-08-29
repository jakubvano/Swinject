//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

struct ContextDescriptor {
    let type: Any.Type
    private let unwrappedType: Any.Type

    init(type: Any.Type) {
        self.type = type
        unwrappedType = unwrapOptionals(type)
    }
}

extension ContextDescriptor: Hashable {
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(unwrappedType).hash(into: &hasher)
    }

    static func == (lhs: ContextDescriptor, rhs: ContextDescriptor) -> Bool {
        return lhs.unwrappedType == rhs.unwrappedType
    }
}

extension ContextDescriptor {
    static let anyContext = ContextDescriptor(type: Any.self)
}
