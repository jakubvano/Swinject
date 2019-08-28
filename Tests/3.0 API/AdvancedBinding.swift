//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

import Nimble
import Quick
import Swinject
@testable import class Swinject.UnboundScope

class AdvancedBindingSpec: QuickSpec { override func spec() { #if swift(>=5.1)
    beforeEach {
        UnboundScope.root.close()
    }
    it("can register a common binding for all sub types") {
        let swinject = Swinject {
            register().subtypeFactory(for: BaseClass.self) { actualType, _ in actualType.init() }
        }
        expect { try instance(of: BaseClass.self).from(swinject) }.notTo(throwError())
        expect { try instance(of: SubClass1.self).from(swinject) }.notTo(throwError())
        expect { try instance(of: SubClass2.self).from(swinject) }.notTo(throwError())
    }
    it("throws if requesting type with wrong tag") {
        let swinject = Swinject {
            register().subtypeFactory(for: BaseClass.self, tag: "tag") { actualType, _ in actualType.init() }
        }
        expect { try instance(of: SubClass1.self).from(swinject) }.to(throwError())
    }
    it("throws if requesting type with wrong arguments") {
        let swinject = Swinject {
            register().subtypeFactory(for: BaseClass.self) { actualType, _ in actualType.init() }
        }
        expect { try instance(of: SubClass1.self, arg: "42").from(swinject) }.to(throwError())
    }
    it("throws if has multiple bindings for type") {
        let swinject = Swinject {
            register().subtypeFactory(for: BaseClass.self) { actualType, _ in actualType.init() }
            register().factory { SubClass1() }
        }
        expect { try instance(of: SubClass1.self).from(swinject) }.to(throwError())
    }
    it("can register a common binding for a singleton") {
        let swinject = Swinject {
            registerSingle().subtypeFactory(for: BaseClass.self) { actualType, _ in actualType.init() }
        }
        let first = try? instance(of: SubClass1.self).from(swinject)
        let second = try? instance(of: SubClass1.self).from(swinject)
        expect(first) === second
    }
    #endif
} }

class BaseClass {
    required init() {}
}

class SubClass1: BaseClass {}
class SubClass2: BaseClass {}
