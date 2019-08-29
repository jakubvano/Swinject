//
//  Copyright © 2019 Swinject Contributors. All rights reserved.
//

import Nimble
import Quick
import Swinject
@testable import class Swinject.UnboundScope

class SubtypeBindingSpec: QuickSpec { override func spec() { #if swift(>=5.1)
    beforeEach {
        UnboundScope.root.close()
    }
    describe("class factory") {
        it("can register a common binding for all subclasses") {
            let swinject = Swinject {
                register().classFactory(for: BaseClass.self) { $0.init() }
            }
            expect { try instance(of: BaseClass.self).from(swinject) }.notTo(throwError())
            expect { try instance(of: SubClass1.self).from(swinject) }.notTo(throwError())
            expect { try instance(of: SubClass2.self).from(swinject) }.notTo(throwError())
        }
        it("throws if requesting type with wrong tag") {
            let swinject = Swinject {
                register().classFactory(for: BaseClass.self, tag: "tag") { $0.init() }
            }
            expect { try instance(of: SubClass1.self).from(swinject) }.to(throwError())
        }
        it("throws if requesting type with wrong arguments") {
            let swinject = Swinject {
                register().classFactory(for: BaseClass.self) { $0.init() }
            }
            expect { try instance(of: SubClass1.self, arg: "42").from(swinject) }.to(throwError())
        }
    }
    describe("context") {
        it("throws if requesting type on wrong context") {
            let swinject = Swinject {
                register(inContextOf: String.self).classFactory(for: BaseClass.self) { $0.init() }
            }
            expect { try instance(of: SubClass1.self).from(swinject.on(42)) }.to(throwError())
        }
        it("can unse common binding without context on any context") {
            let swinject = Swinject {
                register().classFactory(for: BaseClass.self) { $0.init() }
            }
            expect { try instance(of: SubClass1.self).from(swinject.on("context")) }.notTo(throwError())
        }
        it("can use common binding on context optional") {
            let swinject = Swinject {
                register(inContextOf: String.self).classFactory(for: BaseClass.self) { $0.init() }
            }
            expect { try instance(of: SubClass1.self).from(swinject.on("context" as String?)) }.notTo(throwError())
        }
    }
    describe("singletons") {
        it("can register a common binding for a singleton") {
            let swinject = Swinject {
                registerSingle().classFactory(for: BaseClass.self) { $0.init() }
            }
            let first = try? instance(of: SubClass1.self).from(swinject)
            let second = try? instance(of: SubClass1.self).from(swinject)
            expect(first) === second
        }
    }
    describe("checks") {
        it("ignores common binding if also has specific binding for type") {
            var invoked = false
            let swinject = Swinject {
                register().classFactory(for: BaseClass.self) { invoked = true; return $0.init() }
                register().factory { SubClass1() }
            }
            _ = try? instance(of: SubClass1.self).from(swinject)
            expect(invoked) == false
        }
        it("ignores common binding when checking overrides") {
            expect {
                _ = Swinject {
                    register().classFactory(for: BaseClass.self) { $0.init() }
                    register().classFactory(for: BaseClass.self) { $0.init() }
                }
            }.notTo(throwAssertion())
        }
        it("does not ignore common binding when checking dependencies") {
            expect {
                _ = Swinject {
                    register().constant("name")
                    register().resultOf(Pet.init^)
                    register().classFactory(for: Human.self) { _ in Human() }
                }
            }.notTo(throwAssertion())
        }
    }
    describe("any type factory") {
        it("can register common binding for any protocol implementation") {
            let swinject = Swinject {
                register()
                    .anyTypeFactory { ($0 as! BaseProtocol.Type).init() }
                    .toUseWhen { $0 is BaseProtocol.Type }
            }
            expect { try instance(of: BaseClass.self).from(swinject) }.notTo(throwError())
            expect { try instance(of: SubClass1.self).from(swinject) }.notTo(throwError())
            expect { try instance(of: SubClass2.self).from(swinject) }.notTo(throwError())
        }
        it("does not use common binding for non-matching types") {
            let swinject = Swinject {
                register()
                    .anyTypeFactory { _ in 42 }
                    .toUseWhen { $0 is Int.Type }
            }
            expect { try instance(of: String.self).from(swinject) }.to(throwError(errorType: NoBinding.self))
        }
    }
    #endif
} }

protocol BaseProtocol {
    init()
}

class BaseClass: BaseProtocol {
    required init() {}
}

class SubClass1: BaseClass {}
class SubClass2: BaseClass {}
