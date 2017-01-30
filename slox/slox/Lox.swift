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
    
    for token in tokens {
        print(token)
    }
}

func error(line: Int, message: String) {
    report(line: line, where: "", message: message)
}

var hadError = false
func report(line: Int, where location: String, message: String) {
    print("[line \(line)] Error \(location): \(message)")
    hadError = true
}
