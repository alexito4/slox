//
//  Priner.swift
//  GenerateAst
//
//  Created by Alejandro Martinez on 17/02/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

class Printer {
    private var output = ""
    private var indent = 0

    func emptyline() {
        print("")
    }

    func print(_ text: String) {
        let tab = "    "
        var spacing = ""
        for _ in 0 ..< indent {
            spacing += tab
        }
        Swift.print(spacing + text, to: &output)
    }

    func push() {
        indent += 1
    }

    func pop() {
        indent -= 1
    }

    func write(to path: URL) throws {
        try output.write(to: path, atomically: true, encoding: .utf8)
    }
}
