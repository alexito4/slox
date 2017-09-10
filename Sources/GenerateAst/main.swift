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

    let fields = fieldsList.components(separatedBy: ", ").filter({ $0.isEmpty == false })

    // Properties
    p.push()
    for field in fields {
        p.print("let \(field)")
    }

    p.emptyline()

    // Initializer
    if fields.isEmpty == false {
        p.print("init(\(fieldsList)) {")
        p.push()
        for field in fields {
            let name = field.components(separatedBy: ": ")[0].trimmingCharacters(in: .whitespaces)

            p.print("self.\(name) = \(name)")
        }
        p.pop()
        p.print("}")
    }

    // Visitor pattern.
    p.emptyline()
    p.print("override func accept<V: \(visitorName(baseName)), R>(visitor: V) -> R where R == V.\(returnName(baseName)) {")
    p.push()
    p.print("return visitor.visit" +
        className + baseName + "(self)")
    p.pop()
    p.print("}")
    p.pop()

    p.print("}")
}

func visitorName(_ baseName: String) -> String {
    return "\(baseName)Visitor"
}

func returnName(_ baseName: String) -> String {
    return "\(visitorName(baseName))Return"
}

func defineVisitor(baseName: String, types: [String]) {
    p.print("protocol \(visitorName(baseName)) {")

    p.emptyline()
    p.push()
    p.print("associatedtype \(returnName(baseName))")
    p.pop()
    p.emptyline()

    p.push()
    for type in types {
        let typeName = type.components(separatedBy: "/")[0].trimmingCharacters(in: .whitespaces)
        p.print("func visit\(typeName)\(baseName)(_ \(baseName.lowercased()): \(baseName).\(typeName)) -> \(returnName(baseName))")
    }
    p.pop()

    p.print("}")
}

func defineAst(outputDir: String, baseName: String, types: [String]) throws {

    p.emptyline()

    // The Visitor protocol.
    defineVisitor(baseName: baseName, types: types)
    p.emptyline()

    // The Base class.
    p.print("class \(baseName) {")
    p.push()

    // The base accept() method.
    p.emptyline()
    p.print("func accept<V: \(visitorName(baseName)), R>(visitor: V) -> R where R == V.\(returnName(baseName)) {")
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

    print("\(baseName) generated in \(path)")
}

p = Printer()
try defineAst(outputDir: outputDir, baseName: "Expr", types: [
    "Assign   / name: Token, value: Expr",
    "Binary   / left: Expr, op: Token, right: Expr",
    "Call     / callee: Expr, paren: Token, arguments: Array<Expr>",
    "Grouping / expression: Expr",
    "Literal  / value: Any?",
    "Logical  / left: Expr, op: Token, right: Expr",
    "Unary    / op: Token, right: Expr",
    "Variable / name: Token",
])

p = Printer()
try defineAst(outputDir: outputDir, baseName: "Stmt", types: [
    "Block      / statements: Array<Stmt>",
    "Break      /",
    "Expression / expression: Expr",
    "Function   / name: Token, parameters: Array<Token>, body: Array<Stmt>",
    "If         / condition: Expr, thenBranch: Stmt, elseBranch: Stmt?",
    "Print      / expression: Expr",
    "Return     / keyword: Token, value: Expr?",
    "Var        / name: Token, initializer: Expr?",
    "While      / condition: Expr, body: Stmt",
])
