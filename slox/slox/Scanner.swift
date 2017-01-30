//
//  Scanner.swift
//  slox
//
//  Created by Alejandro Martinez on 29/01/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

class Scanner {
    
    private let source: String
    private var tokens = [Token]()
    
    private var start: String.CharacterView.Index
    private var current: String.CharacterView.Index
    private var line = 1
    
    init(source: String) {
        self.source = source
        
        self.start = source.characters.startIndex
        self.current = self.start
    }
    
    func scanTokens() -> [Token] {
        
        while isAtEnd() == false {
            // We are at the beginning of the next lexeme.
            start = current
            scanToken()
        }
        
        let finalToken = Token(type: .eof, lexeme: "", literal: nil, line: line)
        tokens.append(finalToken)
        
        return tokens
    }
    
    private func isAtEnd() -> Bool {
        return current == source.endIndex
    }
    
    func scanToken() {
        let c = advance()
        switch c {
        case "(":
            addToken(type: .leftParen)
        case ")":
            addToken(type: .rightParen)
        case "{":
            addToken(type: .leftBrace)
        case "}":
            addToken(type: .rightBrace)
        case ",":
            addToken(type: .comma)
        case ".":
            addToken(type: .dot)
        case "-":
            addToken(type: .minus)
        case "+":
            addToken(type: .plus)
        case ";":
            addToken(type: .semicolon)
        case "*":
            addToken(type: .star)
            
        case "!" where match("="):
            addToken(type: .bangEqual)
        case "!":
            addToken(type: .bangEqual)
            
        case "=" where match("="):
            addToken(type: .equalEqual)
        case "=":
            addToken(type: .equal)
            
        case "<" where match("="):
            addToken(type: .lessEqual)
        case "<":
            addToken(type: .less)
            
        case ">" where match("="):
            addToken(type: .greaterEqual)
        case ">":
            addToken(type: .greater)
            
        case "/" where match("/"):
            // A comment goes until the end of the line.
            while peek() != "\n" && isAtEnd() == false {
                _ = advance()
            }
        case "/" where match("*"):
            // C-style /* ... */ block comments.
            // TODO: Allow nesting.
            while peek() != "*" && peekNext() != "/" && isAtEnd() == false {
                if peek() == "\n" {
                    line += 1
                }
                _ = advance()
            }
            guard peek() == "*" else {
                error(line: line, message: "Multiline comment not closed with '*/'")
                break
            }
            _ = advance()
            
            guard peek() == "/" else {
                error(line: line, message: "Multiline comment not closed, missing '/'")
                break
            }
            _ = advance()
            
        case "/":
            addToken(type: .slash)
            
        case " ", "\r", "\t":
            // Ingore whitespace
            break
            
        case "\n":
            line += 1
            
        case "\"":
            string()
            
        case _ where isDigit(c):
            number()
            
        case _ where isAlpha(c):
            identifier()
            
        default:
            error(line: line, message: "Unexpected character.")
        }
    }
    
    private func identifier() {
        while isAlphaNumeric(peek()) {
            _ = advance()
        }
        
        // See if the identifier is a reserver word
        let text = source.substring(with: start..<current)
        
        let type = Scanner.keywords[text] ?? .identifier
        addToken(type: type)
    }
    
    private func number() {
        while isDigit(peek()) {
            _ = advance()
        }
        
        // Look for a fractional part.
        if peek() == "." && isDigit(peekNext()) {
            // Consume the "."
            _ = advance()
        }
        
        while isDigit(peek()) {
            _ = advance()
        }
        
        let numberString = source.substring(with: start..<current)
        // FIXME: Robustness
        let number = Double(numberString)!
        addToken(type: .number, literal: number)
    }
    
    private func string() {
        while peek() != "\"" && isAtEnd() == false {
            if peek() == "\n" {
                line += 1
            }
            _ = advance()
        }
        
        // Unterminated string
        if isAtEnd() {
            error(line: line, message: "Unterminated string.")
            return
        }
        
        // The closing ".
        _ = advance()
        
        // Trim the surrounding quotes.
        let afterStart = source.characters.index(after: start)
        let beforeCurrent = source.characters.index(before: current)
        let value = source.substring(with: afterStart..<beforeCurrent)
        addToken(type: .string, literal: value)
    }
    
    private func match(_ expected: Character) -> Bool {
        guard isAtEnd() == false else { return false }
        guard source.characters[current] == expected else { return false }
        
        current = source.index(after: current)
        return true
    }
    
    private func peek() -> Character {
        guard current != source.characters.endIndex else { return "\0" }
        return source.characters[current]
    }
    
    private func peekNext() -> Character {
        guard current != source.endIndex else { return "\0" }

        let next = source.index(after: current)
        guard next != source.endIndex else { return "\0" }
        
        return source.characters[next]
    }
    
    private func isDigit(_ c: Character) -> Bool {
        let digits = CharacterSet.decimalDigits
        // FIXME: Robustness
        return digits.contains(String(c).unicodeScalars.first!)
    }
    
    private func isAlpha(_ c: Character) -> Bool {
        // FIXME: Robustness
        let u = String(c).unicodeScalars.first!
        return CharacterSet.lowercaseLetters.contains(u)
            || CharacterSet.uppercaseLetters.contains(u)
            || u == "_"
        
    }
    
    private func isAlphaNumeric(_ c: Character) -> Bool {
        // NOTE: This could use CharacterSet.alphanumerics
        return isAlpha(c) || isDigit(c)
    }
    
    private func advance() -> Character {
        let prev = current
        current = source.index(after: current)
        let char = source.characters[prev]
        return char
    }
    
    private func addToken(type: TokenType, literal: Any? = nil) {
        let text = source.substring(with: start..<current)
        let token = Token(type: type, lexeme: text, literal: literal, line: line)
        tokens.append(token)
    }
}

extension Scanner {
    
    static let keywords: Dictionary<String, TokenType> = [
        "and": .and,
        "class": .Class,
        "else": .Else,
        "false": .False,
        "for": .For,
        "fun": .fun,
        "if": .If,
        "nil":  .Nil,
        "or": .or,
        "print": .print,
        "return": .Return,
        "super": .Super,
        "this": .this,
        "true": .True,
        "var": .Var,
        "while": .While
    ]
}
