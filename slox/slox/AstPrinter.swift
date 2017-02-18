//
//  AstPrinter.swift
//  slox
//
//  Created by Alejandro Martinez on 17/02/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

// Creates an unambiguous, if ugly, string representation of AST nodes.
class AstPrinter {
    
    func print(expr: Expr) -> String {
        switch expr {
        case let .binary(left, op, right):
            return parenthesize(name: op.lexeme, exprs: left, right)
        case let .grouping(grouped):
            return parenthesize(name: "group", exprs: grouped)
        case let .literal(value):
            return String(describing: value)
        case let .unary(op, right):
            return parenthesize(name: op.lexeme, exprs: right)
        }
    }
    
    private func parenthesize(name: String, exprs: Expr...) -> String {
        var output = ""
        
        output.append("(\(name)")
        
        for expr in exprs {
            output.append(" ")
            output.append(print(expr: expr))
        }
        
        output.append(")")
        
        return output
    }
}

// Chapter 5. Extra 3. In Reverse Polish Notation
class AstRPNPrinter {
    
    func print(expr: Expr) -> String {
        switch expr {
        case let .binary(left, op, right):
            return "\(print(expr: left)) \(print(expr: right)) \(op.lexeme)"
        case let .grouping(grouped):
            return print(expr: grouped)
        case let .literal(value):
            return String(describing: value)
        case let .unary(op, right):
            return "\(print(expr: right)) \(op.lexeme)"
        }
    }
    
}
