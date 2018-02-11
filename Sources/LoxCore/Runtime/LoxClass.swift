//
//  LoxClass.swift
//  LoxCore
//
//  Created by Alejandro Martinez on 04/11/2017.
//

import Foundation

// Runtime representation of a Class.
// LoxClass implements LoxCallable for the initialization syntax. Creating a instance is done by calling a method
// on the class.

final class LoxClass: LoxCallable {
    let name: String
    let superclass: LoxClass?
    private let methods: Dictionary<String, LoxFunction>

    init(name: String, superclass: LoxClass?, methods: Dictionary<String, LoxFunction>) {
        self.name = name
        self.methods = methods
        self.superclass = superclass
    }

    // LoxCallable

    var arity: Int {
        if let initializer = methods["init"] {
            return initializer.arity
        } else {
            return 0
        }
    }

    func call(interpreter: Interpreter, arguments: Array<Any>) throws -> Any? {
        let instance = LoxInstance(klass: self)

        if let initializer = methods["init"] {
            _ = try initializer.bind(instance).call(interpreter: interpreter, arguments: arguments)
        }

        return instance
    }

    func findMethod(instance: LoxInstance, name: String) -> LoxFunction? {
        if let method = methods[name] {
            return method.bind(instance)
        }

        if let superclass = superclass {
            return superclass.findMethod(instance: instance, name: name)
        }

        return nil
    }
}

extension LoxClass: CustomDebugStringConvertible {
    var debugDescription: String {
        // "LoxClass: \(name)"
        return name
    }
}
