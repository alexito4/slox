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

    init(tokens: Array<Token>) {
        self.tokens = tokens
    }

    func parse() -> Array<Stmt>? {

        var statements = Array<Stmt>()
        
        do {
            while !isAtEnd() {
                statements.append(try statement())
            }
        } catch {
            return nil
        }
        
        return statements
    }

    // MARK: Grammar

    private func expression() throws -> Expr {
        return try equiality()
    }
    
    private func statement() throws -> Stmt {
        if match(.print) {
            return try printStatement()
        }
        
        return try expressionStatement()
    }
    
    private func printStatement() throws -> Stmt {
        let value = try expression()
        try consume(.semicolon, message: "Expect ';' after value.")
        return Stmt.Print(expression: value)
    }
    
    private func expressionStatement() throws -> Stmt {
        let value = try expression()
        try consume(.semicolon, message: "Expect ';' after value.")
        return Stmt.Expression(expression: value)
    }

    private func equiality() throws -> Expr {
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

        return try primary()
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
