//
//  Environment.swift
//  slox
//
//  Created by Alejandro Martinez on 01/06/2017.
//
//

import Foundation

final class Environment {
    
    // Any is optional because uninitialized variables are nil.
    private var values = Dictionary<String, Any?>()
    
    func define(name: String, value: Any?) {
        values[name] = value
    }
    
    func valueFor(name: Token) throws -> Any? {
        if values.contains(where: { (key, value) in key == name.lexeme }) {
            return values[name.lexeme]!
        }
        
        throw InterpreterError.runtime(name, "Undefined variable '\(name.lexeme)'.")
    }
}
