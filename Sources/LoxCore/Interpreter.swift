//
//  Interpreter.swift
//  slox
//
//  Created by Alejandro Martinez on 30/05/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation
import Result

enum InterpreterError: Error {
    case runtime(Token, String) // TODO: Instead of string we could have different cases for each error.
}

final class Interpreter: ExprVisitor, StmtVisitor {

    typealias ExprVisitorReturn = Result<Any, InterpreterError>?
    typealias StmtVisitorReturn = Result<Void, InterpreterError>

    private var environment = Environment()

    func interpret(_ statements: Array<Stmt>) {
        do {
            for statement in statements {
                try execute(statement)
            }
        } catch {
            Lox.runtimeError(error: error)
        }
    }

    private func execute(_ statement: Stmt) throws {
        if case let .failure(error) = statement.accept(visitor: self) {
            throw error
        }
    }

    private func executeBlock(_ statements: Array<Stmt>, newEnvironment: Environment) throws {
        let previous = environment
        environment = newEnvironment
        defer {
            environment = previous
        }

        for statement in statements {
            try execute(statement)
        }
    }

    private func stringify(value: Any?) -> String {
        guard let value = value else { return "nil" }

        // Hack. Work around Swift adding ".0" to integer-valued doubles.
        if value is Double {
            var text = String(describing: value)
            if text.hasSuffix(".0") {
                text = text.substring(to: text.index(text.endIndex, offsetBy: -2))
            }
            return text
        }

        return String(describing: value)
    }

    // MARK: ExprVisitor

    func visitLiteralExpr(_ expr: Expr.Literal) -> ExprVisitorReturn {
        guard let value = expr.value else {
            return nil
        }
        return .success(value)
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) -> ExprVisitorReturn {
        let res = evaluate(expr: expr.expression)
        return res
    }

    func visitUnaryExpr(_ expr: Expr.Unary) -> ExprVisitorReturn {
        let right = evaluate(expr: expr.right)

        switch expr.op.type {
        case .bang:
            return .success(!isTrue(right))
        case .minus:
            let casted = castNumberOperand(op: expr.op, operand: right)
            return casted.map(-)

        case .leftParen, .rightParen: fallthrough
        case .leftBrace, .rightBrace: fallthrough
        case .comma: fallthrough
        case .dot: fallthrough
        case .plus: fallthrough
        case .semicolon: fallthrough
        case .slash: fallthrough
        case .star: fallthrough
        case .bangEqual: fallthrough
        case .equal: fallthrough
        case .equalEqual: fallthrough
        case .greater, .greaterEqual: fallthrough
        case .less, .lessEqual: fallthrough
        case .identifier: fallthrough
        case .string: fallthrough
        case .number: fallthrough
        case .and: fallthrough
        case .Class: fallthrough
        case .Else: fallthrough
        case .False: fallthrough
        case .fun: fallthrough
        case .For: fallthrough
        case .If: fallthrough
        case .Nil: fallthrough
        case .or: fallthrough
        case .print: fallthrough
        case .Return: fallthrough
        case .Super: fallthrough
        case .this: fallthrough
        case .True: fallthrough
        case .Var: fallthrough
        case .While: fallthrough
        case .eof:
            // Unreachable.
            fatalError()
        }
    }

    func visitVariableExpr(_ expr: Expr.Variable) -> ExprVisitorReturn {
        do {
            let value = try environment.valueFor(name: expr.name)
            return .success(value as Any)
        } catch {
            return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
        }
    }

    func visitBinaryExpr(_ expr: Expr.Binary) -> ExprVisitorReturn {
        let left = evaluate(expr: expr.left)
        let right = evaluate(expr: expr.right)

        switch expr.op.type {
        case .minus:
            return castNumberOperands(op: expr.op, left: left, right: right).map({ $0.0 - $0.1 })
        case .slash:
            return castNumberOperands(op: expr.op, left: left, right: right).map({ $0.0 / $0.1 })
        case .star:
            return castNumberOperands(op: expr.op, left: left, right: right).map({ $0.0 * $0.1 })
        case .plus:

            guard let left = left, let right = right else {
                return .failure(InterpreterError.runtime(expr.op, "Operands must not be nil."))
            }

            guard case let .success(ls) = left else {
                return left // returns the error
            }

            guard case let .success(rs) = right else {
                return right // returns the error
            }

            if let lDouble = ls as? Double, let rDouble = rs as? Double {
                return .success(lDouble + rDouble)
            }

            if let lString = ls as? String, let rString = rs as? String {
                return .success(lString + rString)
            }

            return .failure(InterpreterError.runtime(expr.op, "Operands must be two numbers or two strings."))

        case .greater:
            return castNumberOperands(op: expr.op, left: left, right: right).map({ $0.0 > $0.1 })
        case .greaterEqual:
            return castNumberOperands(op: expr.op, left: left, right: right).map({ $0.0 >= $0.1 })
        case .less:
            return castNumberOperands(op: expr.op, left: left, right: right).map({ $0.0 < $0.1 })
        case .lessEqual:
            return castNumberOperands(op: expr.op, left: left, right: right).map({ $0.0 <= $0.1 })

        case .bangEqual:
            return .success(!isEqualAny(left: left, right: right))
        case .equalEqual:
            return .success(isEqualAny(left: left, right: right))

        case .leftParen, .rightParen: fallthrough
        case .leftBrace, .rightBrace: fallthrough
        case .comma: fallthrough
        case .dot: fallthrough
        case .semicolon: fallthrough
        case .bang: fallthrough
        case .equal: fallthrough
        case .identifier: fallthrough
        case .string: fallthrough
        case .number: fallthrough
        case .and: fallthrough
        case .Class: fallthrough
        case .Else: fallthrough
        case .False: fallthrough
        case .fun: fallthrough
        case .For: fallthrough
        case .If: fallthrough
        case .Nil: fallthrough
        case .or: fallthrough
        case .print: fallthrough
        case .Return: fallthrough
        case .Super: fallthrough
        case .this: fallthrough
        case .True: fallthrough
        case .Var: fallthrough
        case .While: fallthrough
        case .eof:
            // Unreachable.
            fatalError()
        }
    }

    func visitAssignExpr(_ expr: Expr.Assign) -> ExprVisitorReturn {
        switch evaluate(expr: expr.value) {
        case .success(let value)?:

            do {
                try environment.assign(name: expr.name, value: value)
            } catch {
                return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
            }

            return .success(value)

        case .failure(let error)?:
            return .failure(error)
        default:
            fatalError()
        }
    }

    private func evaluate(expr: Expr) -> ExprVisitorReturn {
        return expr.accept(visitor: self)
    }

    // ugh, again, unnecessary code just to make Result, Any and Optional play together.
    private func isTrue(_ result: ExprVisitorReturn) -> Bool {
        guard let result = result else {
            return false
        }

        switch result {
        case .success(let object):
            return isTrue(object)
        case .failure:
            return false
        }
    }

    private func isTrue(_ object: Any?) -> Bool {
        guard let object = object else {
            return false
        }

        if let b = object as? Bool {
            return b
        }

        return true
    }

    private func isEqualAny(left: ExprVisitorReturn, right: ExprVisitorReturn) -> Bool {
        // nil is only equal to nil.
        if left == nil && right == nil {
            return true
        }

        guard let left = left?.value, let right = right?.value else {
            return false
        }

        return isEqualAny(left: left, right: right)
    }

    private func isEqualAny(left: Any?, right: Any?) -> Bool {
        // nil is only equal to nil.
        if left == nil && right == nil {
            return true
        }

        if left == nil {
            return false
        }

        guard type(of: left!) == type(of: right!) else {
            // Types are different.
            return false
        }

        if let l = left as? String, let r = right as? String {
            return l == r
        }

        if let l = left as? Bool, let r = right as? Bool {
            return l == r
        }

        if let l = left as? Double, let r = right as? Double {
            return l == r
        }

        fatalError("Unsupported equatable type. /n \(String(describing: left)) or \(String(describing: right))")
    }

    // MARK: Runtime checks

    private func castNumberOperands(op: Token, left: ExprVisitorReturn, right: ExprVisitorReturn) -> Result<(Double, Double), InterpreterError> {
        guard let left = left, let right = right else {
            return .failure(InterpreterError.runtime(op, "Operands must not be nil."))
        }

        guard case let .success(ls) = left else {
            return .failure(left.error!)
        }

        guard case let .success(rs) = right else {
            return .failure(right.error!)
        }

        if let l = ls as? Double, let r = rs as? Double {
            return .success(l, r)
        }

        return .failure(InterpreterError.runtime(op, "Operands must be numbers."))
    }

    private func castNumberOperand(op: Token, operand: ExprVisitorReturn) -> Result<Double, InterpreterError> {
        guard let operand = operand else {
            return .failure(InterpreterError.runtime(op, "Operand must not be nil."))
        }

        guard case let .success(num) = operand else {
            return .failure(operand.error!)
        }

        if let res = num as? Double {
            return .success(res)
        }

        return .failure(InterpreterError.runtime(op, "Operand must be a number."))
    }

    // MARK: StmtVisitor

    func visitBlockStmt(_ stmt: Stmt.Block) -> StmtVisitorReturn {

        do {
            try executeBlock(stmt.statements, newEnvironment: Environment(enclosing: environment))
        } catch {
            return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
        }

        return .success()
    }

    func visitExpressionStmt(_ stmt: Stmt.Expression) -> StmtVisitorReturn {
        if case let .failure(error)? = evaluate(expr: stmt.expression) {
            return .failure(error)
        }

        return .success()
    }

    func visitPrintStmt(_ stmt: Stmt.Print) -> StmtVisitorReturn {
        switch evaluate(expr: stmt.expression) {
        case .success(let value)?:
            print(stringify(value: value))
            return .success()
        case .failure(let error)?:
            return .failure(error)
        case nil:
            print(stringify(value: nil))
            return .success()
        }
    }

    func visitVarStmt(_ stmt: Stmt.Var) -> StmtVisitorReturn {
        let value: Any
        if let initializer = stmt.initializer {
            switch evaluate(expr: initializer) {
            case .success(let res)?:
                value = res
            case .failure(let error)?:
                return .failure(error)
            default:
                fatalError()
            }
        } else {
            value = NilAny
        }

        environment.define(name: stmt.name.lexeme, value: value)

        return .success()
    }
}
