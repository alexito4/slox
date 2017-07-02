# slox
Swift implementation of a **Lox** interpreter

This project contains a Swift implementation of the **Lox** language following the book [Crafting Interpreters](http://www.craftinginterpreters.com) written by [Bob Nystrom](https://twitter.com/munificentbob). [Crafting Interpreters in GitHub](https://github.com/munificent/craftinginterpreters)

Programming languages and compilers are one of my biggest interests, following the Swift evolution list and watching Jonathan Blow develop his new language are two of my hobbies. I've played with parsers in the past, and tried to mess around with the missing metaprogramming features in Swift but I've never tried to implement a complete language. Although I understand the theory behind it I was missing the motivation to get my hands dirty, motivation that Bob's book seems to have given me!

The plan here is to follow Bob's work on the book and implement the chapters one by one in Swift. I'm really curious to see how Swift is suited for this kind of work.

One thing to note is that I'm trying to write a mix between idiomatic Swift (whatever that means in this young language) and the code that the book shows in Java. Because I'm not making up the language nor the compiler/interpreter but I'm following the book I don't want to get into a point where in future chapters the book asks for some code changes and they get too complex because I was trying to be too smart. So I take it as a learning exercise and try to implement it as close as possible, except for those occasions where I can't resist using Swift nice features like `guard` or the powerful `switch` statements. There will be time to maybe write another compiler that explores different ways of doing things, but this is not it.

# Implementation

*as of 02/07/2017*

## A TREE-WALK INTERPRETER

- [x] 4.  [**Scanning**](http://www.craftinginterpreters.com/scanning.html) - [Lox Interpreter in Swift](http://alejandromp.com/blog/2017/1/30/lox-interpreter-in-swift/)
  - [x] Challenge 4: C-style /* ... */ block comments.

- [x] 5.  [**Representing Code**](http://www.craftinginterpreters.com/representing-code.html)
  - [x] Challenge 3: AST Printer In Reverse Polish Notation.
  - [x] GenerateAst tool
  - Things to explore:
    - Is there a better way to metaprogram the expression classes? Or is there even a need to metaprogram them with Swift cleaner syntax?
    - Does Swift offer a better model for defining the expressions? 
    - Implemented Enums with methods and pattern matching in [another branch](https://github.com/alexito4/slox/blob/Expr_enum/slox/slox/Expr.swift#L11).

- [x] 6. [**Parsing Expressions**](http://www.craftinginterpreters.com/parsing-expressions.html) 
  - [x] Helper method for parsing left-associative series of binary operators. *Swift can't pass variadic arguments between functions (no array splatting), so it's a little bit hugly.*
  - [ ] Challenge 1: Add prefix and postfix ++ and -- operators.
  - [ ] Challenge 2: Add support for the C-style conditional or “ternary” operator `?:`
  - [ ] Challenge 3: Add error productions to handle each binary operator appearing without a left-hand operand.

- [x] 7. [**Evaluating Expressions**](http://www.craftinginterpreters.com/evaluating-expressions.html)
  - [ ] Challenge 1: Allowing comparisons on types other than numbers could be useful.
  - [ ] Challenge 2: Many languages define + such that if either operand is a string, the other is converted to a string and the results are then concatenated.
  - [ ] Challenge 3: Change the implementation in visitBinary() to detect and report a runtime error when dividing by 0. 

- [x] 8. [**Statements and State**](http://www.craftinginterpreters.com/statements-and-state.html)
  - [ ] Challenge 1: Add support to the REPL to let users type in both statements and expressions.
  - [ ] Challenge 2: Make it a runtime error to access a variable that has not been initialized or assigned to
  - Challenge 3: Nothing to implement.

- [ ] 9. [**Control Flow**](http://www.craftinginterpreters.com/control-flow.html)
  - Challenge 1: Nothing to implement.
  - Challenge 2: Nothing to implement.
  - [ ] Challenge 3: Add support for break statements.

- [ ] 10. [**Functions**](http://www.craftinginterpreters.com/functions.html) (COMING SOON)
- [ ] 11. [**Resolving and Binding**](http://www.craftinginterpreters.com/resolving-and-binding.html) (COMING SOON)
- [ ] 12. [**Classes**](http://www.craftinginterpreters.com/classes.html) (COMING SOON)
- [ ] 13. [**Inheritance**](http://www.craftinginterpreters.com/inheritance.html) (COMING SOON)

# Tests

I integrated Bob tests in order to be able to make sure this implementation behaves in the same way as the original implementation. You can find the [test](https://github.com/alexito4/slox/tree/master/test) in this project with the `test.py` [script modified](https://github.com/alexito4/slox/blob/master/tools/test.py) to work with this project. You can also find a [diff](https://github.com/alexito4/slox/blob/master/tools/test_patch.diff) with the main modifications.

Example of usage: `sh build.sh; ./tools/test.py chap08_statements`

# Project structure

This project now uses [SPM](https://github.com/apple/swift-package-manager/) to manage the executables, framework and dependencies.

The bulk of the interpreter is implemented in a framework and the executable is just a small CLI program that uses that framework.

- slox: The executable. Can be used as a CLI to run the interpreter.
- LoxCore: The main framework that contains the implementation of the Lox language in Swift.
- GenerateAst: A small executable that generates the AST for LoxCore.

# Author

Alejandro Martinez | http://alejandromp.com | [@alexito4](https://twitter.com/alexito4)
