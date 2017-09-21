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
    case breakLoop // Thrown by the Break Stmt to get out of the loop
    case ret(Any?) // Thrown by the Return Stmt to unwind the call stack
}

// TODO: Temporal, implement proper protocols by generating the code
// but in any case... we want identify based on the reference...
// maybe the issue is that we shouldn't use a Dictionary but a container that uses reference types directly by their pointers (NSDictioanry?).
extension Expr: Hashable {
    var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }

    static func ==(lhs: Expr, rhs: Expr) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

final class Interpreter: ExprVisitor, StmtVisitor {

    typealias ExprVisitorReturn = Result<Any, InterpreterError>?
    typealias StmtVisitorReturn = Result<Void, InterpreterError>

    private let globals = Environment()
    private var locals: Dictionary<Expr, Int> = [:]
    private var environment: Environment

    init() {
        environment = globals

        globals.define(name: "clock", value: AnonymousCallable(arity: 0) { interpreter, args in
            return Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
        })
    }

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

    func executeBlock(_ statements: Array<Stmt>, newEnvironment: Environment) throws {
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

    // Used by the Resolver Variable resolution pass
    func resolve(_ expr: Expr, depth: Int) {
        locals[expr] = depth
    }

    // MARK: ExprVisitor

    func visitLiteralExpr(_ expr: Expr.Literal) -> ExprVisitorReturn {
        guard let value = expr.value else {
            return nil
        }
        return .success(value)
    }

    func visitLogicalExpr(_ expr: Expr.Logical) -> Result<Any, InterpreterError>? {
        let left = evaluate(expr: expr.left)

        // Logical operator with shortcircuit
        switch expr.op.type {
        case .or where isTruthy(left):
            return left
        case .and where isTruthy(left) == false:
            return left
        default:
            return evaluate(expr: expr.right)
        }
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) -> ExprVisitorReturn {
        let res = evaluate(expr: expr.expression)
        return res
    }

    func visitUnaryExpr(_ expr: Expr.Unary) -> ExprVisitorReturn {
        let right = evaluate(expr: expr.right)

        switch expr.op.type {
        case .bang:
            return .success(!isTruthy(right))
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
        case .Break: fallthrough
        case .eof:
            // Unreachable.
            fatalError()
        }
    }

    func visitVariableExpr(_ expr: Expr.Variable) -> ExprVisitorReturn {
        do {
            let value = try lookUpVariable(name: expr.name, expr: expr)
            return .success(value as Any)
        } catch {
            return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
        }
    }

    private func lookUpVariable(name: Token, expr: Expr) throws -> Any {
        if let distance = locals[expr] {
            return try environment.valueFor(name: name, atDistance: distance)
        } else {
            return try globals.valueFor(name: name)
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
                return .failure(InterpreterError.runtime(expr.op, "Operands must be two numbers or two strings.")) // Operands must not be nil.
            }

            guard case let .success(ls) = left else {
                return left // returns the error
            }

            guard case let .success(rs) = right else {
                return right // returns the error
            }

            // I'm not a fan of automatically casting things to String but the dynamism of the
            // language asks for it.
            if ls is String || rs is String {
                let lString = stringify(value: ls)
                let rString = stringify(value: rs)
                return .success(lString + rString)
            }

            if let lDouble = ls as? Double, let rDouble = rs as? Double {
                return .success(lDouble + rDouble)
            }

            //            if let lString = ls as? String, let rString = rs as? String {
            //                return .success(lString + rString)
            //            }

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
        case .Break: fallthrough
        case .eof:
            // Unreachable.
            fatalError()
        }
    }

    func visitCallExpr(_ expr: Expr.Call) -> ExprVisitorReturn {
        let calleeResult = evaluate(expr: expr.callee)

        guard let callee = calleeResult?.value, let function = callee as? Callable else {
            return .failure(InterpreterError.runtime(expr.paren, "Can only call functions and classes."))
        }

        var arguments: Array<Any> = []
        for argument in expr.arguments {
            let argResult = evaluate(expr: argument)
            guard let arg = argResult?.value else {
                return argResult
            }
            arguments.append(arg)
        }

        guard arguments.count == function.arity else {
            return .failure(InterpreterError.runtime(expr.paren, "Expected \(function.arity) arguments but got \(arguments.count)."))
        }

        do {
            if let value = try function.call(interpreter: self, arguments: arguments) {
                return .success(value)
            } else {
                return nil
            }
        } catch {
            return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
        }
    }

    func visitFunctionExpr(_ expr: Expr.Function) -> Result<Any, InterpreterError>? {
        let value = Function(name: nil, declaration: expr, closure: environment)
        return .success(value)
    }

    func visitAssignExpr(_ expr: Expr.Assign) -> ExprVisitorReturn {
        switch evaluate(expr: expr.value) {
        case .success(let value)?:

            do {
                if let distance = locals[expr] {
                    try environment.assign(name: expr.name, value: value, atDistance: distance)
                } else {
                    try globals.assign(name: expr.name, value: value)
                }
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
    private func isTruthy(_ result: ExprVisitorReturn) -> Bool {
        guard let result = result else {
            return false
        }

        switch result {
        case .success(let object):
            return isTruthy(object)
        case .failure:
            return false
        }
    }

    private func isTruthy(_ object: Any?) -> Bool {
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
            return .failure(InterpreterError.runtime(op, "Operands must be numbers.")) // Operands must not be nil.
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

    func visitBreakStmt(_ stmt: Stmt.Break) -> Result<Void, InterpreterError> {
        return .failure(.breakLoop)
    }

    func visitExpressionStmt(_ stmt: Stmt.Expression) -> StmtVisitorReturn {
        if case let .failure(error)? = evaluate(expr: stmt.expression) {
            return .failure(error)
        }

        return .success()
    }

    func visitFunctionStmt(_ stmt: Stmt.Function) -> Result<Void, InterpreterError> {
        let function = Function(name: stmt.name.lexeme, declaration: stmt.function, closure: environment)
        environment.define(name: stmt.name.lexeme, value: function)
        return .success()
    }

    func visitIfStmt(_ stmt: Stmt.If) -> Result<Void, InterpreterError> {
        if isTruthy(evaluate(expr: stmt.condition)) {
            do {
                try execute(stmt.thenBranch)
            } catch {
                return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
            }
        } else if let elseBranch = stmt.elseBranch {
            do {
                try execute(elseBranch)
            } catch {
                return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
            }
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

    func visitReturnStmt(_ stmt: Stmt.Return) -> Result<Void, InterpreterError> {
        var value: Any?

        if let valueExpr = stmt.value {
            let result = evaluate(expr: valueExpr)
            switch result {
            case nil:
                break
            case .success(let res)?:
                value = res
            case .failure(let error)?:
                return .failure(error)
            }
        }

        return .failure(.ret(value))
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

    func visitWhileStmt(_ stmt: Stmt.While) -> Result<Void, InterpreterError> {
        while isTruthy(evaluate(expr: stmt.condition)) {
            do {
                try execute(stmt.body)
            } catch InterpreterError.breakLoop {
                break
            } catch {
                return .failure(error as! InterpreterError) // Compiler doesn't know but it should always be InterpreterError
            }
        }
        return .success()
    }
}
