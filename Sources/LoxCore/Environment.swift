//
//  Environment.swift
//  slox
//
//  Created by Alejandro Martinez on 01/06/2017.
//
//

import Foundation
import Result

// This is a hack to make Swift useful when working with Any and Optional.
// You can't know, not even at runtime, if an Any is an Optional (it always says yes).
// So to store Any (including nil) in the enviornment we just use Any instead of Any? and use this value
// to denote nil.
// Otherwise you start having Optional nested many times that will break the stringify output and probably
// any other execution that tries to use it.
let NilAny: Any = Optional<Any>.none as Any

final class Environment {

    var enclosing: Environment?

    // Any is optional because uninitialized variables are nil.
    private var values = Dictionary<String, Any>()

    init() {
        enclosing = nil
    }

    init(enclosing: Environment) {
        self.enclosing = enclosing
    }

    /// Pass any value, but for nil use `NilAny`
    func define(name: String, value: Any) {
        assert((value is Result<Any, InterpreterError>) == false, "Trying to store a Result instead of the value?")
        values[name] = value
    }

    func valueFor(name: Token) throws -> Any {
        if values.contains(where: { key, value in key == name.lexeme }) {
            if let unwrapped = values[name.lexeme] {
                return unwrapped
            }
            return NilAny
        }

        if let enclosing = enclosing {
            return try enclosing.valueFor(name: name)
        }

        throw InterpreterError.runtime(name, "Undefined variable '\(name.lexeme)'.")
    }

    func assign(name: Token, value: Any) throws {
        if values.contains(where: { key, value in key == name.lexeme }) {
            values[name.lexeme] = value
            return
        }

        if let enclosing = enclosing {
            try enclosing.assign(name: name, value: value)
        }

        throw InterpreterError.runtime(name, "Undefined variable '\(name.lexeme)'.")
    }
}
