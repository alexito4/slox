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

    func call(interpreter: Interpreter, arguments: Array<Any>) -> Any
}

// To create functions with closures.
// Java has anonymous class for this.
// Could add and overloaded `define` function to Enviornment but not sure if later
// I will need this for something else.
final class AnonymousCallable: Callable {

    let arity: Int
    let callClosure: (Interpreter, Array<Any>) -> Any

    init(arity: Int, call: @escaping (Interpreter, Array<Any>) -> Any) {
        self.arity = arity
        callClosure = call
    }

    func call(interpreter: Interpreter, arguments: Array<Any>) -> Any {
        return callClosure(interpreter, arguments)
    }
}
