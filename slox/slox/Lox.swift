//
//  Lox.swift
//  slox
//
//  Created by Alejandro Martinez on 29/01/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

func runFile(path: String) throws {
    let url = URL(fileURLWithPath: path)
    let code = try String(contentsOf: url)
    run(code)

    if hadError {
        exit(65)
    }
}

func runPrompt() {
    while true {
        print("> ")
        guard let code = readLine() else { continue }
        run(code)

        hadError = false
    }
}

func run(_ code: String) {
    let scanner = Scanner(source: code)
    let tokens = scanner.scanTokens()

    let parser = Parser(tokens: tokens)
    let expr = parser.parse()

    if !hadError {
        precondition(expr != nil, "Parser didn't return an Expression but there was no error reported")

        print(AstPrinter().print(expr: expr!))
    }
}

func error(line: Int, message: String) {
    report(line: line, where: "", message: message)
}

func error(token: Token, message: String) {
    if token.type == .eof {
        report(line: token.line, where: " at end", message: message)
    } else {
        report(line: token.line, where: " at '\(token.lexeme)'", message: message)
    }
}

var hadError = false
func report(line: Int, where location: String, message: String) {
    print("[line \(line)] Error \(location): \(message)")
    hadError = true
}
