//
//  LoxCallable.swift
//  slox
//
//  Created by Alejandro Martinez on 10/09/2017.
//
//

import Foundation

// Runtime representation of something that can be used with function call syntax.

protocol LoxCallable {
    // Number of arguments.
    var arity: Int { get }

    func call(interpreter: Interpreter, arguments: Array<Any>) throws -> Any?

    // TESTING
    func bind(_ instance: LoxInstance) -> LoxCallable
}

// To create functions with closures.
// Java has anonymous class for this.
// Could add and overloaded `define` function to Enviornment but not sure if later
// I will need this for something else.
final class AnonymousCallable: LoxCallable {

    let arity: Int
    let callClosure: (Interpreter, Array<Any>) throws -> Any?

    init(arity: Int, call: @escaping (Interpreter, Array<Any>) throws -> Any?) {
        self.arity = arity
        callClosure = call
    }

    func call(interpreter: Interpreter, arguments: Array<Any>) throws -> Any? {
        return try callClosure(interpreter, arguments)
    }

    // TESTING
    func bind(_ instance: LoxInstance) -> LoxCallable {
        return self
    }
}

final class LoxFunction: LoxCallable, CustomDebugStringConvertible, Equatable {

    private let name: String?
    private let declaration: Stmt.Function
    private let closure: Environment
    private let isInitializer: Bool
    let arity: Int

    init(name: String?, declaration: Stmt.Function, closure: Environment, isInitializer: Bool) {
        self.name = name
        self.declaration = declaration
        self.closure = closure
        self.isInitializer = isInitializer

        arity = declaration.parameters.count
    }

    func call(interpreter: Interpreter, arguments: Array<Any>) throws -> Any? {
        let environment = Environment(enclosing: closure)

        for (i, param) in declaration.parameters.enumerated() {
            environment.define(name: param.lexeme, value: arguments[i])
        }

        do {
            try interpreter.executeBlock(declaration.body, newEnvironment: environment)
        } catch InterpreterError.ret(let value) {
            return value ?? nil
        } catch {
            throw error
        }

        if isInitializer {
            return try closure.valueFor(name: "this", atDistance: 0)
        }

        return nil
    }

    func bind(_ instance: LoxInstance) -> LoxCallable {
        let env = Environment(enclosing: closure)
        env.define(name: "this", value: instance)
        return LoxFunction(name: name, declaration: declaration, closure: env, isInitializer: isInitializer)
    }

    var debugDescription: String {
        guard let name = self.name else {
            return "<fn>"
        }
        return "<fn \(name)>"
    }

    static func ==(lhs: LoxFunction, rhs: LoxFunction) -> Bool {
        return lhs.name == rhs.name &&
            //        lhs.declaration.name.lexeme == rhs.declaration.name.lexeme &&
            //        lhs.declaration.body == rhs.declaration.body &&
            //        lhs.declaration.parameters == rhs.declaration.parameters &&
            lhs.closure === rhs.closure
    }
}
