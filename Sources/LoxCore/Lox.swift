//
//  Lox.swift
//  slox
//
//  Created by Alejandro Martinez on 29/01/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

public final class Lox {
    public final class Logger {
        public var output: (String) -> Void
        public var error: (String) -> Void

        init() {
            output = {
                Swift.print($0)
            }
            error = {
                var stderr = FileHandle.standardError
                Swift.print($0, to: &stderr)
            }
        }

        func print(_ text: String) {
            output(text)
        }

        func report(_ text: String) {
            error(text)
        }
    }

    public static var logger = Logger()

    static let interpreter = Interpreter()

    public static func runFile(path: String) throws {
        let url = URL(fileURLWithPath: path)
        let code = try String(contentsOf: url)
        run(code)

        if hadError {
            exit(65)
        }
        if hadRuntimeError {
            exit(70)
        }
    }

    public static func runPrompt() {
        while true {
            print("> ")
            guard let code = readLine() else { continue }
            run(code)

            hadError = false
        }
    }

    public static func runCode(_ code: String) {
        defer {
            // Clean up static state in case it gets run multiple times
            hadError = false
        }

        run(code)
    }

    private static func run(_ code: String) {
        let scanner = Scanner(source: code)
        let tokens = scanner.scanTokens()

        let parser = Parser(tokens: tokens)
        let statements = parser.parse()

        // Stop if there was a syntax error.
        guard !hadError else {
            return
        }

        let resolver = Resolver(interpreter: interpreter)
        resolver.resolve(statements: statements)

        // Stop if there was a resolution error.
        guard !hadError else {
            return
        }

        interpreter.interpret(statements)

        /*
         if !hadError {
         precondition(expr != nil, "Parser didn't return an Expression but there was no error reported")

         print(AstPrinter().print(expr: expr!))
         }*/
    }

    // MARK: - Error Reporting

    // MARK: Compile time error

    static func error(line: Int, message: String) {
        report(line: line, where: "", message: message)
    }

    static func error(token: Token, message: String) {
        if token.type == .eof {
            report(line: token.line, where: " at end", message: message)
        } else {
            report(line: token.line, where: " at '\(token.lexeme)'", message: message)
        }
    }

    static var hadError = false
    static func report(line: Int, where location: String, message: String) {
        Lox.logger.report("[line \(line)] Error\(location): \(message)")
        hadError = true
    }

    // MARK: Runtime errors

    static var hadRuntimeError = false
    static func runtimeError(error: Error) {
        guard let interError = error as? InterpreterError else {
            fatalError()
        }
        guard case let InterpreterError.runtime(token, message) = interError else {
            fatalError()
        }
        var stderr = FileHandle.standardError
        print("\(message)\n[line \(token.line)]", to: &stderr)
        hadRuntimeError = true
    }
}

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        write(data)
    }
}
