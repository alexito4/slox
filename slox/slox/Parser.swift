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

    func parse() -> Expr? {
        do {
            return try expression()
        } catch {
            return nil
        }
    }

    // MARK: Grammar

    private func expression() throws -> Expr {
        return try equiality()
    }

    private func equiality() throws -> Expr {
        var expr = try comparison()

        while match(.bangEqual, .equalEqual) {
            let op = previous()
            let right = try comparison()
            expr = Expr.Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func comparison() throws -> Expr {
        var expr = try term()

        while match(.greater, .greaterEqual, .less, .lessEqual) {
            let op = previous()
            let right = try term()
            expr = Expr.Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func term() throws -> Expr {
        var expr = try factor()

        while match(.minus, .plus) {
            let op = previous()
            let right = try factor()
            expr = Expr.Binary(left: expr, op: op, right: right)
        }

        return expr
    }

    private func factor() throws -> Expr {
        var expr = try unary()

        while match(.slash, .star) {
            let op = previous()
            let right = try unary()
            expr = Expr.Binary(left: expr, op: op, right: right)
        }

        return expr
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
            _ = try consume(.rightParen, message: "Expect ')' after expression.")
            return Expr.Grouping(expression: expr)
        }

        throw error(token: peek(), message: "Expect expression.")
    }
}

// MARK: Parsing infrastructure
extension Parser {

    func match(_ types: TokenType...) -> Bool {
        for type in types {
            if check(type) {
                _ = advance()
                return true
            }
        }

        return false
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
        slox.error(token: token, message: message)
        return Error.parseFailure
    }
}
