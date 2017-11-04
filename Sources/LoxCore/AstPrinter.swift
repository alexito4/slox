//
//  AstPrinter.swift
//  slox
//
//  Created by Alejandro Martinez on 17/02/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

// Creates an unambiguous, if ugly, string representation of AST nodes.
class AstPrinter: ExprVisitor, StmtVisitor {

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }

    func print(stmt: Stmt) -> String {
        return stmt.accept(visitor: self)
    }

    // MARK: ExprVisitor

    func visitAssignExpr(_ expr: Expr.Assign) -> String {
        return parenthesize(name: "=", parts: expr.name.lexeme, expr.value)
    }

    func visitBinaryExpr(_ expr: Expr.Binary) -> String {
        return parenthesize(name: expr.op.lexeme, exprs: expr.left, expr.right)
    }

    func visitCallExpr(_ expr: Expr.Call) -> String {
        return parenthesize(name: "call", parts: expr.callee, expr.arguments)
    }

    func visitGetExpr(_ expr: Expr.Get) -> String {
        return parenthesize(name: ".", parts: expr.object, expr.name.lexeme)
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) -> String {
        return parenthesize(name: "group", exprs: expr.expression)
    }

    func visitLiteralExpr(_ expr: Expr.Literal) -> String {
        guard let value = expr.value else {
            return "nil"
        }
        return String(describing: value)
    }

    func visitLogicalExpr(_ expr: Expr.Logical) -> String {
        return parenthesize(name: expr.op.lexeme, exprs: expr.left, expr.right)
    }

    func visitSetExpr(_ expr: Expr.Set) -> String {
        return parenthesize(name: "=", parts: expr.object, expr.name.lexeme, expr.value)
    }

    func visitThisExpr(_ expr: Expr.This) -> String {
        return "this"
    }

    func visitUnaryExpr(_ expr: Expr.Unary) -> String {
        return parenthesize(name: expr.op.lexeme, exprs: expr.right)
    }

    func visitVariableExpr(_ expr: Expr.Variable) -> String {
        return expr.name.lexeme
    }

    func visitWhileStmt(_ stmt: Stmt.While) -> String {
        return parenthesize(name: "while", parts: stmt.condition, stmt.body)
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

    // MARK: StmtVisitor

    func visitBlockStmt(_ stmt: Stmt.Block) -> String {
        var output = ""

        output.append("(block ")

        for statement in stmt.statements {
            output.append(statement.accept(visitor: self))
        }

        return output
    }

    func visitClassStmt(_ stmt: Stmt.Class) -> String {
        var output = ""
        output += ("(class " + stmt.name.lexeme)

        //        if (stmt.superclass != null) {
        //            builder.append(" < " + print(stmt.superclass));
        //        }

        for method in stmt.methods {
            output += " " + method.accept(visitor: self)
        }

        output += ")"
        return output
    }

    func visitBreakStmt(_ stmt: Stmt.Break) -> String {
        return "(break)"
    }

    func visitExpressionStmt(_ stmt: Stmt.Expression) -> String {
        return parenthesize(name: ";", exprs: stmt.expression)
    }

    func visitFunctionStmt(_ stmt: Stmt.Function) -> String {
        var res = "(fun \(stmt.name.lexeme)"

        res += "("
        for param in stmt.parameters {
            res += " \(param.lexeme)"
        }
        res += ") "

        for body in stmt.body {
            res += body.accept(visitor: self)
        }

        return res
    }

    func visitIfStmt(_ stmt: Stmt.If) -> String {
        guard let elseBranch = stmt.elseBranch else {
            return parenthesize(name: "if", parts: stmt.condition, stmt.thenBranch)
        }

        return parenthesize(name: "if-else", parts: stmt.condition, stmt.thenBranch, elseBranch)
    }

    func visitPrintStmt(_ stmt: Stmt.Print) -> String {
        return parenthesize(name: "print", exprs: stmt.expression)
    }

    func visitReturnStmt(_ stmt: Stmt.Return) -> String {
        guard let value = stmt.value else {
            return "(return)"
        }
        return parenthesize(name: "return", parts: value)
    }

    func visitVarStmt(_ stmt: Stmt.Var) -> String {
        guard let initializer = stmt.initializer else {
            return parenthesize(name: "var", parts: stmt.name)
        }

        return parenthesize(name: "var", parts: stmt.name, "=", initializer)
    }

    private func parenthesize(name: String, parts: Any...) -> String {
        var output = ""

        output.append("(")

        output.append(name)

        for part in parts {
            output.append(" ")

            if let expr = part as? Expr {
                output.append(expr.accept(visitor: self))
            } else if let stmt = part as? Stmt {
                output.append(stmt.accept(visitor: self))
            } else if let token = part as? Token {
                output.append(token.lexeme)
            } else {
                output.append(String(describing: part))
            }
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

    func visitAssignExpr(_ expr: Expr.Assign) -> String {
        fatalError("unimplemented")
    }

    func visitBinaryExpr(_ expr: Expr.Binary) -> String {
        return "\(print(expr: expr.left)) \(print(expr: expr.right)) \(expr.op.lexeme)"
    }

    func visitCallExpr(_ expr: Expr.Call) -> String {
        fatalError("unimplemented")
    }

    func visitGetExpr(_ expr: Expr.Get) -> String {
        fatalError("unimplemented")
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) -> String {
        return print(expr: expr.expression)
    }

    func visitLiteralExpr(_ expr: Expr.Literal) -> String {
        return String(describing: expr.value)
    }

    func visitLogicalExpr(_ expr: Expr.Logical) -> String {
        return "\(print(expr: expr.left)) \(print(expr: expr.right)) \(expr.op.lexeme)"
    }

    func visitSetExpr(_ expr: Expr.Set) -> String {
        fatalError("unimplemented")
    }

    func visitThisExpr(_ expr: Expr.This) -> String {
        fatalError("unimplemented")
    }

    func visitUnaryExpr(_ expr: Expr.Unary) -> String {
        return "\(print(expr: expr.right)) \(expr.op.lexeme)"
    }

    func visitVariableExpr(_ expr: Expr.Variable) -> String {
        fatalError("unimplemented")
    }
}
