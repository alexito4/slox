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
