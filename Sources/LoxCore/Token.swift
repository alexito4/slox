//
//  Token.swift
//  slox
//
//  Created by Alejandro Martinez on 29/01/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

enum TokenType {
    // Single-character tokens.
    case leftParen, rightParen
    case leftBrace, rightBrace
    case comma
    case dot
    case minus
    case plus
    case semicolon
    case slash
    case star

    // One or two character tokens
    case bang, bangEqual
    case equal, equalEqual
    case greater, greaterEqual
    case less, lessEqual

    // Literals
    case identifier
    case string
    case number

    // Keywords
    case and
    case Class
    case Else
    case False
    case fun
    case For
    case If
    case Nil
    case or
    case print
    case Return
    case Super
    case this
    case True
    case Var
    case While

    case Break

    case eof
}

struct Token: CustomStringConvertible {
    let type: TokenType
    let lexeme: String
    let literal: Any?
    let line: Int

    init(type: TokenType, lexeme: String, literal: Any? = nil, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }

    var description: String {
        let literalText: String
        if let literal = literal {
            literalText = " -> '\(literal)'"
        } else {
            literalText = ""
        }
        return "\(type): '\(lexeme)'\(literalText)"
    }
}
