//
//  Environment.swift
//  slox
//
//  Created by Alejandro Martinez on 01/06/2017.
//
//

import Foundation
import Result

final class Environment {
    
    // Any is optional because uninitialized variables are nil.
    private var values = Dictionary<String, Any?>()
    
    func define(name: String, value: Any?) {
//        assert(value is Result) // compiler segmentation fault
        assert((value is Optional<Result<Any, InterpreterError>>) == false, "Trying to store a Result instead of the value?")
        values[name] = value
    }
    
    func valueFor(name: Token) throws -> Any? {
        if values.contains(where: { (key, value) in key == name.lexeme }) {
            return values[name.lexeme]!
        }
        
        throw InterpreterError.runtime(name, "Undefined variable '\(name.lexeme)'.")
    }
    
    func assign(name: Token, value: Any?) throws {
        if values.contains(where: { (key, value) in key == name.lexeme }) {
            values[name.lexeme] = value
            return
        }
        
        throw InterpreterError.runtime(name, "Undefined variable '\(name.lexeme)'.")
    }
}
