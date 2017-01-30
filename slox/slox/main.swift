//
//  main.swift
//  slox
//
//  Created by Alejandro Martinez on 29/01/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

let args = CommandLine.arguments
print("Arguments: \(args)")

guard args.count <= 2 else {
    print("Usage: slox [script]")
    exit(1)
}

if args.count == 2 {
    try runFile(path: args[1])
} else {
    runPrompt()
}





