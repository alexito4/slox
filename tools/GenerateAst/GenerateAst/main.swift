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

// PRINTING HELPER
var p: Printer!
//

func defineType(baseName: String, className: String, fields fieldsList: String) {
    p.print("class \(className): \(baseName) {")

    let fields = fieldsList.components(separatedBy: ", ")

    // Properties
    p.push()
    for field in fields {
        p.print("let \(field)")
    }
    
    p.emptyline()
    
    // Initializer
    p.print("init(\(fieldsList)) {")
    p.push()
    for field in fields {
        let name = field.components(separatedBy: ": ")[0].trimmingCharacters(in: .whitespaces)
        
        p.print("self.\(name) = \(name)")
    }
    p.pop()
    p.print("}")
    
    // Visitor pattern.
    p.emptyline()
    p.print("override func accept<V: Visitor, R>(visitor: V) -> R where R == V.Return {")
    p.push()
    p.print("return visitor.visit" +
        className + baseName + "(self)")
    p.pop()
    p.print("}")
    p.pop()

    p.print("}")
}

func defineVisitor(baseName: String, types: [String]) {
    p.print("protocol Visitor {")
    
    p.emptyline()
    p.push()
    p.print("associatedtype Return")
    p.pop()
    p.emptyline()

    p.push()
    for type in types {
        let typeName = type.components(separatedBy: "/")[0].trimmingCharacters(in: .whitespaces)
        p.print("func visit\(typeName)\(baseName)(_ \(baseName.lowercased()): \(baseName).\(typeName)) -> Return")
        
    }
    p.pop()
    
    p.print("}")
}

func defineAst(outputDir: String, baseName: String, types: [String]) throws {

    p.emptyline()

    // The Visitor protocol.
    defineVisitor(baseName: baseName, types: types);
    p.emptyline()

    // The Base class.
    p.print("class \(baseName) {")
    p.push()

    // The base accept() method.
    p.emptyline()
    p.print("func accept<V: Visitor, R>(visitor: V) -> R where R == V.Return {")
    p.push()
    p.print("fatalError()")
    p.pop()
    p.print("}")

    // The AST classes.
    p.emptyline()
    for type in types {
        let components = type.components(separatedBy: "/")
        let className = components[0].trimmingCharacters(in: .whitespaces)
        let fields = components[1].trimmingCharacters(in: .whitespaces)
        defineType(baseName: baseName, className: className, fields: fields)
        
        p.emptyline()
    }
    
    p.pop()
    p.print("}")
    

    
    let path = URL(fileURLWithPath: "\(baseName).swift", relativeTo: URL(fileURLWithPath: outputDir))
    try p.write(to: path)
}

p = Printer()
try defineAst(outputDir: outputDir, baseName: "Expr", types: [
    "Binary   / left: Expr, op: Token, right: Expr",
    "Grouping / expression: Expr",
    "Literal  / value: Any",
    "Unary    / op: Token, right: Expr",
])

