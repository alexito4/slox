//
//  Callable.swift
//  slox
//
//  Created by Alejandro Martinez on 10/09/2017.
//
//

import Foundation

protocol Callable {
    // Number of arguments.
    var arity: Int { get }

    func call(interpreter: Interpreter, arguments: Array<Any>) -> Any?
}

// To create functions with closures.
// Java has anonymous class for this.
// Could add and overloaded `define` function to Enviornment but not sure if later
// I will need this for something else.
final class AnonymousCallable: Callable {

    let arity: Int
    let callClosure: (Interpreter, Array<Any>) -> Any?

    init(arity: Int, call: @escaping (Interpreter, Array<Any>) -> Any?) {
        self.arity = arity
        callClosure = call
    }

    func call(interpreter: Interpreter, arguments: Array<Any>) -> Any? {
        return callClosure(interpreter, arguments)
    }
}

final class Function: Callable, CustomDebugStringConvertible {
    private let declaration: Stmt.Function

    let arity: Int

    init(declaration: Stmt.Function) {
        self.declaration = declaration

        arity = declaration.parameters.count
    }

    func call(interpreter: Interpreter, arguments: Array<Any>) -> Any? {
        let environment = Environment(enclosing: interpreter.globals)

        for (i, param) in declaration.parameters.enumerated() {
            environment.define(name: param.lexeme, value: arguments[i])
        }

        do {
            try interpreter.executeBlock(declaration.body, newEnvironment: environment)
        } catch InterpreterError.ret(let value) {
            return value ?? nil
        } catch {
            fatalError()
        }

        return nil
    }

    var debugDescription: String {
        return "<fn \(declaration.name.lexeme)>"
    }
}
