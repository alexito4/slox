//
//  BuiltIn.swift
//  LoxCore
//
//  Created by Alejandro Martinez on 04/11/2017.
//

import Foundation

// JUST PLAYING AROUND TO MAKE A STDLIB IN SWIFT

class NativeStack: NativeClass {
    var array: Array<Any> = []

    func methods() -> Dictionary<String, LoxCallable> {
        return [
            "debugDescription": AnonymousCallable(arity: 0) { interpreter, arguments in
                return String(describing: self.array)
            },
            "push": AnonymousCallable(arity: 1) { interpreter, arguments in
                self.array.append(arguments[0])
                return ()
            },
            "pop": AnonymousCallable(arity: 0) { interpreter, arguments in
                self.array.removeLast()
                return ()
            },
            "count": AnonymousCallable(arity: 0) { interpreter, arguments in
                return self.array.count
            },
        ]
    }

    static let name = "Stack"
    static func newInstance() -> LoxInstance {
        let nativeInstance = NativeStack()
        let klass = LoxClass(name: NativeStack.name, methods: nativeInstance.methods())
        let instance = LoxInstance(klass: klass)
        return instance
    }
}

protocol NativeClass {
    static var name: String { get }
    static func newInstance() -> LoxInstance
}

final class LoxNativeClass: LoxCallable {
    fileprivate let native: NativeClass.Type

    init(native: NativeClass.Type) {
        self.native = native
    }

    // LoxCallable

    var arity: Int {
        return 0
    }

    func call(interpreter: Interpreter, arguments: Array<Any>) throws -> Any? {
        let instance = native.newInstance()
        return instance
    }

    func bind(_ instance: LoxInstance) -> LoxCallable {
        return self
    }
}

extension LoxNativeClass: CustomDebugStringConvertible {
    var debugDescription: String {
        // "LoxClass: \(name)"
        return String(describing: native)
    }
}
