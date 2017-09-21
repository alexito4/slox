//
//  Resolver.swift
//  slox
//
//  Created by Alejandro Martinez on 20/09/2017.
//
//

import Foundation

// Semantic Analysis.
// Variable resolution pass.
// Each time it visits a variable, it tells the interpreter how many scopes there are between the current scope and the scope where the variable is defined. At runtime, this corresponds exactly to the number of environments between the current one and the enclosing one where interpreter can find the variable’s value.
final class Resolver: ExprVisitor, StmtVisitor {

    private enum FunctionType {
        case none
        case function
    }

    private let interpreter: Interpreter

    private var scopes: Array<Dictionary<String, Bool>> = []
    private var currentFunctionType: FunctionType = .none

    init(interpreter: Interpreter) {
        self.interpreter = interpreter
    }

    private func beginScope() {
        scopes.append([:])
    }

    private func endScope() {
        scopes.removeLast()
    }

    func resolve(statements: Array<Stmt>) {
        for statement in statements {
            resolve(statement)
        }
    }

    private func resolve(_ statement: Stmt) {
        statement.accept(visitor: self)
    }

    private func declare(_ name: Token) {
        guard scopes.isEmpty == false else {
            return
        }

        if scopes[scopes.endIndex - 1][name.lexeme] != nil {
            Lox.error(token: name, message: "Variable with this name already declared in this scope.")
        }

        scopes[scopes.endIndex - 1][name.lexeme] = false
    }

    private func define(_ name: Token) {
        guard scopes.isEmpty == false else {
            return
        }

        scopes[scopes.endIndex - 1][name.lexeme] = true
    }

    private func resolve(_ expr: Expr) {
        expr.accept(visitor: self)
    }

    private func resolveLocal(_ expr: Expr, _ name: Token) {

        for (i, scope) in zip(0 ... scopes.count, scopes).reversed() {
            if scope[name.lexeme] != nil {
                let numOfScopes = scopes.count - 1 - i
                interpreter.resolve(expr, depth: numOfScopes)
                return
            }
        }

        // Not found. Assume it is global.
    }

    private func resolveFunction(_ stmt: Stmt.Function, type: FunctionType) {
        let function = stmt.function
        resolveFunction(function, type: type)
    }

    private func resolveFunction(_ function: Expr.Function, type: FunctionType) {
        let enclosingFunctionType = currentFunctionType
        currentFunctionType = type
        defer { currentFunctionType = enclosingFunctionType }

        beginScope()
        for param in function.parameters {
            declare(param)
            define(param)
        }
        resolve(statements: function.body)
        endScope()
    }

    // MARK: Resolver logic

    func visitBlockStmt(_ stmt: Stmt.Block) {
        beginScope()
        resolve(statements: stmt.statements)
        endScope()
    }

    func visitFunctionStmt(_ stmt: Stmt.Function) {
        declare(stmt.name)
        define(stmt.name)

        resolveFunction(stmt, type: .function)
    }

    func visitFunctionExpr(_ expr: Expr.Function) {
        resolveFunction(expr, type: .function) // .function is right?
    }

    func visitVarStmt(_ stmt: Stmt.Var) {
        declare(stmt.name)
        if let initializer = stmt.initializer {
            resolve(initializer)
        }
        define(stmt.name)
    }

    func visitAssignExpr(_ expr: Expr.Assign) {
        resolve(expr.value)
        resolveLocal(expr, expr.name)
    }

    func visitVariableExpr(_ expr: Expr.Variable) {
        if scopes.isEmpty == false && scopes.last?[expr.name.lexeme] == false {
            Lox.error(token: expr.name, message: "Cannot read local variable in its own initializer.")
        }

        resolveLocal(expr, expr.name)
    }

    // MARK: Traversing the AST

    func visitExpressionStmt(_ stmt: Stmt.Expression) {
        resolve(stmt.expression)
    }

    func visitIfStmt(_ stmt: Stmt.If) {
        resolve(stmt.condition)
        resolve(stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            resolve(elseBranch)
        }
    }

    func visitPrintStmt(_ stmt: Stmt.Print) {
        resolve(stmt.expression)
    }

    func visitReturnStmt(_ stmt: Stmt.Return) {
        if currentFunctionType == .none {
            Lox.error(token: stmt.keyword, message: "Cannot return from top-level code.")
        }

        if let value = stmt.value {
            resolve(value)
        }
    }

    func visitWhileStmt(_ stmt: Stmt.While) {
        resolve(stmt.condition)
        resolve(stmt.body)
    }

    func visitBinaryExpr(_ expr: Expr.Binary) {
        resolve(expr.left)
        resolve(expr.right)
    }

    func visitCallExpr(_ expr: Expr.Call) {
        resolve(expr.callee)

        for argument in expr.arguments {
            resolve(argument)
        }
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) {
        resolve(expr.expression)
    }

    func visitLiteralExpr(_ expr: Expr.Literal) {
        // Literal expression doesn’t mention any variables and doesn’t contain any subexpressions, there is no work to do.
    }

    func visitLogicalExpr(_ expr: Expr.Logical) {
        resolve(expr.left)
        resolve(expr.right)
    }

    func visitUnaryExpr(_ expr: Expr.Unary) {
        resolve(expr.right)
    }

    func visitBreakStmt(_ stmt: Stmt.Break) {
    }
}
