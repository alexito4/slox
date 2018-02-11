//
//  Parser.swift
//  slox
//
//  Created by Alejandro Martinez on 30/03/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

final class Parser {
    enum Error: Swift.Error {
        case parseFailure
    }

    fileprivate var tokens: Array<Token>
    fileprivate var current = 0

    private var loopLevel = 0 // Level of nested loops for break support. Break outside a loop is an error.

    init(tokens: Array<Token>) {
        self.tokens = tokens
    }

    func parse() -> Array<Stmt> {
        var statements = Array<Stmt>()

        while !isAtEnd() {
            if let declaration = declaration() {
                statements.append(declaration)
            }
        }

        return statements
    }

    // MARK: Grammar

    private func expression() throws -> Expr {
        return try assignment()
    }

    private func declaration() -> Stmt? {
        do {
            if match(.Class) {
                return try classDeclaration()
            }
            if check(.fun) && checkNext(.identifier) {
                try consume(.fun, message: "")
                return try function(kind: "function")
            }
            if match(.Var) {
                return try varDeclaration()
            }

            return try statement()
        } catch { // errors should always be Error.parseFailure. If not, we should retrhowit making this func throws.
            synchronize()
            return nil // Recovered from error mode. Return nil and continue parsing.
        }
    }

    private func classDeclaration() throws -> Stmt {
        let name = try consume(.identifier, message: "Expect class name.")

        let superclass: Expr?
        if match(.less) {
            try consume(.identifier, message: "Expect superclass name.")
            superclass = Expr.Variable(name: previous())
        } else {
            superclass = nil
        }

        try consume(.leftBrace, message: "Expect '{' before class body.")

        var methods = Array<Stmt.Function>()
        while !check(.rightBrace) && !isAtEnd() {
            let f = try function(kind: "method")
            methods.append(f)
        }

        try consume(.rightBrace, message: "Expect '}' after class body.")

        return Stmt.Class(name: name, superclass: superclass, methods: methods)
    }

    private func statement() throws -> Stmt {
        if match(.For) {
            return try forStatement()
        }
        if match(.If) {
            return try ifStatement()
        }
        if match(.print) {
            return try printStatement()
        }
        if match(.Return) {
            return try returnStatement()
        }
        if match(.While) {
            return try whileStatement()
        }
        if match(.Break) {
            return try breakStatement()
        }

        if match(.leftBrace) {
            return Stmt.Block(statements: try block())
        }

        return try expressionStatement()
    }

    private func forStatement() throws -> Stmt {
        try consume(.leftParen, message: "Expect '(' after 'for'.")

        let initializer: Stmt?
        if match(.semicolon) {
            initializer = nil
        } else if match(.Var) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }

        let condition: Expr
        if check(.semicolon) == false {
            condition = try expression()
        } else {
            condition = Expr.Literal(value: true)
        }
        try consume(.semicolon, message: "Expect ';' after loop condition.")

        let increment: Expr?
        if check(.rightParen) == false {
            increment = try expression()
        } else {
            increment = nil
        }
        try consume(.rightParen, message: "Expect ')' after for clauses.")

        loopLevel += 1
        defer { loopLevel -= 1 }

        var body = try statement()

        // Synthesize the desugared for into a while
        if let increment = increment {
            body = Stmt.Block(statements: [
                body,
                Stmt.Expression(expression: increment),
            ])
        }

        body = Stmt.While(condition: condition, body: body)

        if let initializer = initializer {
            body = Stmt.Block(statements: [
                initializer,
                body,
            ])
        }

        return body
    }

    private func ifStatement() throws -> Stmt {
        try consume(.leftParen, message: "Expect '(' after 'if'.")
        let condition = try expression()
        try consume(.rightParen, message: "Expect ')' after if condition.")

        let thenBranch = try statement()
        let elseBranch: Stmt?
        if match(.Else) {
            elseBranch = try statement()
        } else {
            elseBranch = nil
        }

        return Stmt.If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }

    private func assignment() throws -> Expr {
        let expr = try or()

        if match(.equal) {
            let equals = previous()
            let value = try assignment()

            if let variable = expr as? Expr.Variable {
                let name = variable.name
                return Expr.Assign(name: name, value: value)
            } else if let get = expr as? Expr.Get {
                return Expr.Set(object: get.object, name: get.name, value: value)
            }

            throw error(token: equals, message: "Invalid assignment target.")
        }

        return expr
    }

    private func or() throws -> Expr {
        var expr = try and()

        while match(.or) {
            let op = previous()
            let right = try and()
            expr = Expr.Logical(left: expr, op: op, right: right)
        }

        return expr
    }

    private func and() throws -> Expr {
        var expr = try equality()

        while match(.and) {
            let op = previous()
            let right = try equality()
            expr = Expr.Logical(left: expr, op: op, right: right)
        }

        return expr
    }

    private func printStatement() throws -> Stmt {
        let value = try expression()
        try consume(.semicolon, message: "Expect ';' after value.")
        return Stmt.Print(expression: value)
    }

    private func returnStatement() throws -> Stmt {
        let keyword = previous()
        var value: Expr?

        if !check(.semicolon) {
            value = try expression()
        }

        try consume(.semicolon, message: "Expect ';' after return value.")

        return Stmt.Return(keyword: keyword, value: value)
    }

    private func varDeclaration() throws -> Stmt {
        let name = try consume(.identifier, message: "Expect variable name.")

        var initializer: Expr?
        if match(.equal) {
            initializer = try expression()
        }

        try consume(.semicolon, message: "Expect ';' after variable declaration.")

        return Stmt.Var(name: name, initializer: initializer)
    }

    private func whileStatement() throws -> Stmt {
        try consume(.leftParen, message: "Expect '(' after 'while'.")
        let condition = try expression()
        try consume(.rightParen, message: "Expect ')' after condition.")

        loopLevel += 1
        defer { loopLevel -= 1 }

        let body = try statement()

        return Stmt.While(condition: condition, body: body)
    }

    private func breakStatement() throws -> Stmt {
        guard loopLevel > 0 else {
            throw error(token: previous(), message: "'break' can't only be used inside a loop.")
        }
        try consume(.semicolon, message: "Expect ';' after 'break'.")
        return Stmt.Break()
    }

    private func expressionStatement() throws -> Stmt {
        let value = try expression()
        try consume(.semicolon, message: "Expect ';' after expression.")
        return Stmt.Expression(expression: value)
    }

    private func function(kind: String) throws -> Stmt.Function {
        let name = try consume(.identifier, message: "Expect \(kind) name.")

        func functionBody(kind: String) throws -> (parameters: Array<Token>, body: Array<Stmt>) {
            try consume(.leftParen, message: "Expect '(' after \(kind) name.")
            var parameters: Array<Token> = []
            if !check(.rightParen) {
                repeat {
                    if parameters.count >= 8 {
                        throw error(token: peek(), message: "Cannot have more than 8 parameters.")
                    }
                    parameters.append(try consume(.identifier, message: "Expect parameter name."))
                } while match(.comma)
            }
            try consume(.rightParen, message: "Expect ')' after parameters.")

            try consume(.leftBrace, message: "Expect '{' before \(kind) body.")
            let body = try block()

            return (parameters, body)
        }

        let (parameters, body) = try functionBody(kind: kind)
        return Stmt.Function(name: name, parameters: parameters, body: body)
    }

    private func block() throws -> Array<Stmt> {
        var statements = Array<Stmt>()

        while !check(.rightBrace) && !isAtEnd() {
            if let decl = declaration() { // If there is an error `decl` is nil, ignore it and continue parsing
                statements.append(decl)
            }
        }

        try consume(.rightBrace, message: "Expect '}' after block.")
        return statements
    }

    private func equality() throws -> Expr {
        return try leftAssociativeBinary(expression: comparison, types: .bangEqual, .equalEqual)
    }

    private func comparison() throws -> Expr {
        return try leftAssociativeBinary(expression: term, types: .greater, .greaterEqual, .less, .lessEqual)
    }

    private func term() throws -> Expr {
        return try leftAssociativeBinary(expression: factor, types: .minus, .plus)
    }

    private func factor() throws -> Expr {
        return try leftAssociativeBinary(expression: unary, types: .slash, .star)
    }

    private func unary() throws -> Expr {
        if match(.bang, .minus) {
            let op = previous()
            let right = try unary()
            return Expr.Unary(op: op, right: right)
        }

        return try call()
    }

    private func call() throws -> Expr {
        var expr = try primary()

        while true {
            if match(.leftParen) {
                expr = try finishCall(callee: expr)
            } else if match(.dot) {
                let name = try consume(.identifier, message: "Expect property name after '.'.")
                expr = Expr.Get(object: expr, name: name)
            } else {
                break
            }
        }

        return expr
    }

    private func finishCall(callee: Expr) throws -> Expr {
        var arguments: Array<Expr> = []

        if !check(.rightParen) {
            repeat {
                if arguments.count >= 8 {
                    _ = error(token: peek(), message: "Cannot have more than 8 arguments.")
                }
                try arguments.append(expression())
            } while match(.comma)
        }

        let paren = try consume(.rightParen, message: "Expect ')' after arguments.")

        return Expr.Call(callee: callee, paren: paren, arguments: arguments)
    }

    private func primary() throws -> Expr {
        if match(.False) {
            return Expr.Literal(value: false)
        }
        if match(.True) {
            return Expr.Literal(value: true)
        }
        if match(.Nil) {
            return Expr.Literal(value: nil)
        }

        if match(.number, .string) {
            return Expr.Literal(value: previous().literal)
        }

        if match(.Super) {
            let keyword = previous()
            try consume(.dot, message: "Expect '.' after 'super'.")
            let method = try consume(.identifier, message: "Expect superclass method name.")
            return Expr.Super(keyword: keyword, method: method)
        }

        if match(.this) {
            return Expr.This(keyword: previous())
        }

        if match(.identifier) {
            return Expr.Variable(name: previous())
        }

        if match(.leftParen) {
            let expr = try expression()
            try consume(.rightParen, message: "Expect ')' after expression.")
            return Expr.Grouping(expression: expr)
        }

        throw error(token: peek(), message: "Expect expression.")
    }

    // MARK: Helper

    private func leftAssociativeBinary(expression side: () throws -> Expr, types: TokenType...) rethrows -> Expr {
        var expr = try side()

        while match(types) {
            let op = previous()
            let right = try side()
            expr = Expr.Binary(left: expr, op: op, right: right)
        }

        return expr
    }
}

// MARK: Parsing infrastructure

extension Parser {
    // Can't pass variadics around so this overload with array is needed :(
    func match(_ types: [TokenType]) -> Bool {
        for type in types {
            if check(type) {
                _ = advance()
                return true
            }
        }

        return false
    }

    func match(_ types: TokenType...) -> Bool {
        return match(types)
    }

    func check(_ tokenType: TokenType) -> Bool {
        if isAtEnd() {
            return false
        }
        return peek().type == tokenType
    }

    func checkNext(_ tokenType: TokenType) -> Bool {
        if isAtEnd() { return false }
        if tokens[current + 1].type == .eof { return false }
        return tokens[current + 1].type == tokenType
    }

    func advance() -> Token {
        if !isAtEnd() {
            current += 1
        }
        return previous()
    }

    func isAtEnd() -> Bool {
        return peek().type == .eof
    }

    func peek() -> Token {
        return tokens[current]
    }

    func previous() -> Token {
        return tokens[current - 1]
    }

    // Similar to `match`
    @discardableResult
    func consume(_ type: TokenType, message: String) throws -> Token {
        if check(type) {
            return advance()
        }

        throw error(token: peek(), message: message)
    }
}

extension Parser {
    func synchronize() {
        _ = advance()

        while !isAtEnd() {
            guard previous().type != .semicolon else {
                return
            }

            switch peek().type {
            case .Class, .fun, .Var, .For, .If, .While, .print, .Return:
                return
            default:
                break
            }

            _ = advance()
        }
    }
}

extension Parser {
    /// Reports the error and returns it so it can be thrown
    func error(token: Token, message: String) -> Error {
        Lox.error(token: token, message: message)
        return Error.parseFailure
    }
}
