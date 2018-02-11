//
//  StmtDebug.swift
//  slox
//
//  Created by Alejandro Martinez on 03/06/2017.
//
//

import Foundation

extension Stmt: CustomDebugStringConvertible {
    var debugDescription: String {
        return AstPrinter().print(stmt: self)
    }
}

extension Expr: CustomDebugStringConvertible {
    var debugDescription: String {
        return AstPrinter().print(expr: self)
    }
}
