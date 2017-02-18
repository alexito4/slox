//
//  ExprEnums.swift
//  slox
//
//  Created by Alejandro Martinez on 18/02/2017.
//  Copyright © 2017 Alejandro Martinez. All rights reserved.
//

import Foundation

indirect enum Expr {
    case binary(left: Expr, op: Token, right: Expr)
    case grouping(Expr)
    case literal(Any)
    case unary(op: Token, right: Expr)
}
