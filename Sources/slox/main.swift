//
//  main.swift
//  slox
//
//  Created by Alejandro Martinez on 29/01/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation
import LoxCore

#if true

    let args = CommandLine.arguments
    print("Arguments: \(args)")

    guard args.count <= 2 else {
        print("Usage: slox [script]")
        exit(1)
    }
    
    if args.count == 2 {
        try Lox.runFile(path: args[1])
    } else {
        Lox.runPrompt()
    }

#else

    // TEST AstPrinter
    let expression = Expr.Binary(
        left: Expr.Unary(
            op: Token(type: .minus, lexeme: "-", line: 1),
            right: Expr.Literal(value: 123)
        ),
        op: Token(type: .star, lexeme: "*", line: 1),
        right: Expr.Grouping(
            expression: Expr.Literal(value: 45.67)
        )
    )

    print(AstPrinter().print(expr: expression))
    print(AstRPNPrinter().print(expr: expression))

#endif
