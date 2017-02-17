//
//  main.swift
//  GenerateAst
//
//  Created by Alejandro Martinez on 17/02/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

let args = CommandLine.arguments
print("Arguments: \(args)")

guard args.count == 2 else {
    print("Usage: generate_ast <output directory>")
    exit(1)
}

let outputDir = args[1]


func defineType(output: inout String, baseName: String, className: String, fields fieldsList: String) {
    print("    class \(className): \(baseName) {", to: &output)

    let fields = fieldsList.components(separatedBy: ", ")

    // Properties
    for field in fields {
        print("        let \(field)", to: &output)
    }
    
    print("", to: &output)

    // Initializer
    print("        init(\(fieldsList)) {", to: &output)
    
    for field in fields {
        let name = field.components(separatedBy: ": ")[0].trimmingCharacters(in: .whitespaces)
        
        print("            self.\(name) = \(name)", to: &output)
    }
    
    print("        }", to: &output)
    
    print("    }", to: &output)
}

func defineAst(outputDir: String, baseName: String, types: [String]) throws {

    var output = ""
    print("", to: &output)

    print("class \(baseName) {", to: &output)
    
    // The AST classes.
    print("", to: &output)
    for type in types {
        let components = type.components(separatedBy: "/")
        let className = components[0].trimmingCharacters(in: .whitespaces)
        let fields = components[1].trimmingCharacters(in: .whitespaces)
        defineType(output: &output, baseName: baseName, className: className, fields: fields)
        
        print("", to: &output)
    }
    
    print("}", to: &output)
    
    let path = URL(fileURLWithPath: "\(baseName).swift", relativeTo: URL(fileURLWithPath: outputDir))
    try output.write(to: path, atomically: true, encoding: .utf8)
}

try defineAst(outputDir: outputDir, baseName: "Expr", types: [
    "Binary   / left: Expr, op: Token, right: Expr",
    "Grouping / expression: Expr",
    "Literal  / value: Any",
    "Unary    / op: Token, right: Expr",
])

