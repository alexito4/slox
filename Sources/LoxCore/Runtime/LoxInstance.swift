//
//  LoxInstance.swift
//  LoxCore
//
//  Created by Alejandro Martinez on 04/11/2017.
//

import Foundation

// Runtime representation of an Instance of a class.

final class LoxInstance {
    fileprivate let klass: LoxClass

    private var fields = Dictionary<String, Any>()

    init(klass: LoxClass) {
        self.klass = klass
    }

    func get(name: Token) throws -> Any {
        if let field = fields[name.lexeme] {
            return field
        }

        if let method = klass.findMethod(instance: self, name: name.lexeme) {
            return method
        }

        throw InterpreterError.runtime(name, "Undefined property '\(name.lexeme)'.")
    }

    func set(name: Token, value: Any) {
        fields[name.lexeme] = value
    }
}

extension LoxInstance: CustomDebugStringConvertible {
    var debugDescription: String {
        return klass.name + " instance"
    }
}
