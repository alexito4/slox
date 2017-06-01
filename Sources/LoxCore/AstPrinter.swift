//
//  AstPrinter.swift
//  slox
//
//  Created by Alejandro Martinez on 17/02/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

// Creates an unambiguous, if ugly, string representation of AST nodes.
class AstPrinter: ExprVisitor {

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }

    func visitBinaryExpr(_ expr: Expr.Binary) -> String {
        return parenthesize(name: expr.op.lexeme, exprs: expr.left, expr.right)
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) -> String {
        return parenthesize(name: "group", exprs: expr.expression)
    }

    func visitLiteralExpr(_ expr: Expr.Literal) -> String {
        return String(describing: expr.value)
    }

    func visitUnaryExpr(_ expr: Expr.Unary) -> String {
        return parenthesize(name: expr.op.lexeme, exprs: expr.right)
    }

    private func parenthesize(name: String, exprs: Expr...) -> String {
        var output = ""

        output.append("(\(name)")

        for expr in exprs {
            output.append(" ")
            output.append(expr.accept(visitor: self))
        }

        output.append(")")

        return output
    }
}

// Chapter 5. Extra 3. In Reverse Polish Notation
class AstRPNPrinter: ExprVisitor {

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }

    func visitBinaryExpr(_ expr: Expr.Binary) -> String {
        return "\(print(expr: expr.left)) \(print(expr: expr.right)) \(expr.op.lexeme)"
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) -> String {
        return print(expr: expr.expression)
    }

    func visitLiteralExpr(_ expr: Expr.Literal) -> String {
        return String(describing: expr.value)
    }

    func visitUnaryExpr(_ expr: Expr.Unary) -> String {
        return "\(print(expr: expr.right)) \(expr.op.lexeme)"
    }
}
