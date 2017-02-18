# slox
Swift implementation of a **Lox** interpreter

This project contains a Swift implementation of the **Lox** language following the book [Crafting Interpreters](http://www.craftinginterpreters.com) written by [Bob Nystrom](https://twitter.com/munificentbob).

Programming languages and compilers are one of my biggest interests, following the Swift evolution list and watching Jonathan Blow develop his new language are two of my hobbies. I've played with parsers in the past, and tried to mess around with the missing metaprogramming features in Swift but I've never tried to implement a complete language. Although I understand the theory behind it I was missing the motivation to get my hands dirty, motivation that Bob's book seems to have given me!

The plan here is to follow Bob's work on the book and implement the chapters one by one in Swift. I'm really curious to see how Swift is suited for this kind of work.

One thing to note is that I'm trying to write a mix between idiomatic Swift (whatever that means in this young language) and the code that the book shows in Java. Because I'm not making up the language nor the compiler/interpreter but I'm following the book I don't want to get into a point where in future chapters the book asks for some code changes and they get too complex because I was trying to be too smart. So I take it as a learning exercise and try to implement it as close as possible, except for those occasions where I can't resist using Swift nice features like `guard` or the powerful `switch` statements. There will be time to maybe write another compiler that explores different ways of doing things, but this is not it.

# Implementation as of 18/02/2017

## A TREE-WALK INTERPRETER

- [x] 4. Scanning
      - Including C-style /* ... */ block comments. (Challenge 4)

- [x] 5. Representing Code

      - Including AST Printer In Reverse Polish Notation. (Challenge 3)
      - Including GenerateAst tool


      - Things to explore:
        - Is there a better way to metaprogram the expression classes? Or is there even a need to metaprogram them with Swift cleaner syntax?
        - Does Swift offer a better model for defining the expressions? 
          - Implemented Enums with methods and pattern matching in [another branch](https://github.com/alexito4/slox/blob/Expr_enum/slox/slox/Expr.swift#L11).

# Author

Alejandro Martinez | http://alejandromp.com | [@alexito4](https://twitter.com/alexito4)